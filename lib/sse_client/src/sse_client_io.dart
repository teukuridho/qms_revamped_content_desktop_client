import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'sse_client_base.dart';
import 'sse_frame.dart';
import 'sse_incremental_id.dart';
import 'sse_parser.dart';
import 'sse_value_parser.dart';

class SseClient implements SseClientBase {
  @override
  final SseClientOptions options;

  final _framesController = StreamController<SseFrame>.broadcast();
  final _parser = SseParser();

  HttpClient? _httpClient;
  HttpClientRequest? _activeRequest;
  StreamSubscription<List<int>>? _subscription;

  bool _closed = false;
  bool _starting = false;
  int _reconnectAttempts = 0;
  String? _lastEventId;
  final SseIncrementalIdValidator _incrementalId = SseIncrementalIdValidator();
  int _connectionId = 0;
  bool _refreshing = false;

  SseClient(this.options);

  @override
  Stream<SseFrame> get frames => _framesController.stream;

  @override
  bool get isRunning => _subscription != null && !_closed;

  @override
  Future<void> start() async {
    if (_closed) {
      throw StateError('SseClient is closed');
    }
    if (_starting || isRunning) return;
    _starting = true;
    try {
      _lastEventId ??= (options.initialLastEventId?.isEmpty ?? true) ? null : options.initialLastEventId;
      await _connectOnce();
      _reconnectAttempts = 0;
    } finally {
      _starting = false;
    }
  }

  Future<void> _connectOnce() async {
    _httpClient ??= HttpClient();

    final uri = options.url;
    final req = await _httpClient!.openUrl('GET', uri);
    _activeRequest = req;

    // Default SSE headers; allow user headers to override.
    req.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
    req.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');

    // Merge headers.
    options.headers.forEach((k, v) {
      req.headers.set(k, v);
    });

    // Standard SSE resume header. Only set if the caller didn't already provide one.
    if (options.sendLastEventIdHeader && _lastEventId != null) {
      final headerName = options.lastEventIdHeaderName;
      final existing = req.headers.value(headerName);
      if (existing == null || existing.isEmpty) {
        req.headers.set(headerName, _lastEventId!);
      }
    }

    // Merge cookies into Cookie header if present.
    if (options.cookies.isNotEmpty) {
      final cookieHeader = _buildCookieHeader(options.cookies);
      if (cookieHeader.isNotEmpty) {
        // If the caller already set Cookie, append rather than replace.
        final existing = req.headers.value(HttpHeaders.cookieHeader);
        req.headers.set(
          HttpHeaders.cookieHeader,
          existing == null || existing.isEmpty ? cookieHeader : '$existing; $cookieHeader',
        );
      }
    }

    Future<HttpClientResponse> responseFuture = req.close();
    if (options.connectTimeout != null) {
      responseFuture = responseFuture.timeout(options.connectTimeout!);
    }
    final res = await responseFuture;

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = await utf8.decodeStream(res).catchError((_) => '');
      throw HttpException(
        'SSE connect failed: ${res.statusCode} ${res.reasonPhrase}${body.isEmpty ? '' : ' - $body'}',
        uri: uri,
      );
    }

    // Listen to response stream.
    final connectionId = ++_connectionId;
    _subscription = res.listen(
      _onBytes,
      onError: (Object e, StackTrace st) {
        _handleDisconnect(e, st, connectionId);
      },
      onDone: () {
        _handleDisconnect(const SocketException('SSE stream closed'), StackTrace.current, connectionId);
      },
      cancelOnError: true,
    );
  }

  void _onBytes(List<int> chunk) {
    if (_closed) return;
    final text = utf8.decode(chunk, allowMalformed: true);
    for (final frame in _parser.add(text)) {
      if (options.enableSseIncrementalIdMismatch) {
        final wasInitialized = _incrementalId.initialized;
        final mismatch = _incrementalId.validate(frame, requireFirstId: true);
        if (mismatch != null) {
          // If the first frame doesn't have a numeric id, stop immediately.
          if (!wasInitialized &&
              (mismatch.reason == SseIncrementalIdMismatchReason.missingId ||
                  mismatch.reason == SseIncrementalIdMismatchReason.nonNumericId)) {
            _safeInvokeMismatchCallback(mismatch);
            _framesController.addError(
              StateError('SSE incremental id mismatch on first frame: ${mismatch.reason}'),
            );
            // ignore: discarded_futures
            close();
            return;
          }

          _safeInvokeMismatchCallback(mismatch);

          // Refresh on mismatch (but do not continue/forward invalid frames).
          // First-frame missing/non-numeric id is still terminal per spec.
          if (options.shouldRefreshWhenIdMismatch && wasInitialized && !_refreshing) {
            _refreshing = true;
            // ignore: discarded_futures
            scheduleMicrotask(() async {
              try {
                await _refreshConnection();
              } finally {
                _refreshing = false;
              }
            });
            return;
          }
        }
      }

      // Update last-event-id if the server sent an `id:` field (including empty reset).
      if (frame.fields.containsKey('id')) {
        final id = frame.id ?? '';
        _lastEventId = id.isEmpty ? null : id;
      }
      _framesController.add(frame);
    }
  }

  Future<void> _refreshConnection() async {
    if (_closed) return;

    // Invalidate callbacks from the old stream.
    _connectionId += 1;

    _activeRequest?.abort();
    _activeRequest = null;

    final sub = _subscription;
    _subscription = null;
    await sub?.cancel();

    _parser.reset();
    _incrementalId.reset();

    try {
      await _connectOnce();
      _reconnectAttempts = 0;
    } catch (e, st) {
      _handleDisconnect(e, st, _connectionId);
    }
  }

  void _safeInvokeMismatchCallback(SseIncrementalIdMismatch mismatch) {
    final cb = options.sseIncrementalMismatchCallback;
    if (cb == null) return;
    try {
      cb(mismatch);
    } catch (e, st) {
      // Never let user callback crash the SSE loop.
      _framesController.addError(e, st);
    }
  }

  void _handleDisconnect(Object error, StackTrace st, int connectionId) {
    // Ignore callbacks from stale connections.
    if (connectionId != _connectionId) return;

    _activeRequest = null;
    final sub = _subscription;
    _subscription = null;
    sub?.cancel();

    if (_closed) return;

    if (!options.autoReconnect) {
      _framesController.addError(error, st);
      return;
    }

    final max = options.maxReconnectAttempts;
    if (max != null && _reconnectAttempts >= max) {
      _framesController.addError(error, st);
      return;
    }

    _reconnectAttempts += 1;
    final delay = options.reconnectDelay;
    Timer(delay, () async {
      if (_closed) return;
      try {
        await start();
      } catch (e, st2) {
        // Propagate failures to listeners; future reconnects still apply.
        _framesController.addError(e, st2);
        _handleDisconnect(e, st2, _connectionId);
      }
    });
  }

  @override
  Stream<T> listen<T>(
    String fieldKey, {
    required SseValueParser<T> parser,
    bool distinct = false,
  }) {
    // Start lazily.
    // Ignore unawaited future; connection lifecycle is handled by frames.
    // ignore: discarded_futures
    start();

    Stream<T> out = frames
        .map((frame) => _extractField(frame, fieldKey))
        .where((v) => v != null)
        .cast<String>()
        .map(parser.parse);

    if (distinct) {
      out = out.distinct();
    }
    return out;
  }

  String? _extractField(SseFrame frame, String fieldKey) {
    final direct = frame.fieldValue(fieldKey);
    if (direct != null) return direct;

    // Standard SSE: match `event: <fieldKey>` and return `data: ...`
    final event = frame.event;
    if (event != null && event == fieldKey) {
      return frame.data;
    }
    return null;
  }

  static String _buildCookieHeader(Map<String, String> cookies) {
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _connectionId += 1;

    _activeRequest?.abort();
    _activeRequest = null;

    await _subscription?.cancel();
    _subscription = null;

    _httpClient?.close(force: true);
    _httpClient = null;

    // Flush any trailing frame.
    for (final frame in _parser.close()) {
      _framesController.add(frame);
    }

    await _framesController.close();
  }
}
