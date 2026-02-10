// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'sse_client_base.dart';
import 'sse_frame.dart';
import 'sse_value_parser.dart';

class SseClient implements SseClientBase {
  @override
  final SseClientOptions options;

  final _framesController = StreamController<SseFrame>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];

  html.EventSource? _eventSource;
  bool _closed = false;

  SseClient(this.options);

  @override
  Stream<SseFrame> get frames => _framesController.stream;

  @override
  bool get isRunning => _eventSource != null && !_closed;

  @override
  Future<void> start() async {
    if (_closed) {
      throw StateError('SseClient is closed');
    }
    if (isRunning) return;

    // Browser EventSource does not allow setting custom headers.
    // Cookies may be sent depending on CORS + credentials policy of the browser.
    final es = html.EventSource(options.url.toString());
    _eventSource = es;

    _subscriptions.add(es.onOpen.listen((_) {
      // no-op
    }));

    _subscriptions.add(es.onError.listen((e) {
      if (_closed) return;
      _framesController.addError(StateError('EventSource error: $e'));
      if (!options.autoReconnect) return;
      // Native EventSource already retries based on server `retry:` hint.
    }));

    // Default "message" events.
    _subscriptions.add(es.onMessage.listen((html.MessageEvent e) {
      final data = e.data?.toString() ?? '';
      _framesController.add(
        SseFrame.fromFields({
          'event': const ['message'],
          'data': [data],
        }),
      );
    }));
  }

  @override
  Stream<T> listen<T>(
    String fieldKey, {
    required SseValueParser<T> parser,
    bool distinct = false,
  }) {
    // Start lazily.
    // ignore: discarded_futures
    start();

    // On web, treat [fieldKey] as the SSE event name (EventSource only exposes data per event).
    // - fieldKey == 'data' or 'message': uses onMessage.
    // - otherwise: adds an event listener for that event type and reads `.data`.
    if (fieldKey == 'data' || fieldKey == 'message') {
      Stream<T> out = frames
          .map((f) => f.data)
          .where((v) => v != null)
          .cast<String>()
          .map(parser.parse);
      if (distinct) out = out.distinct();
      return out;
    }

    final es = _eventSource;
    if (es == null) {
      return Stream<T>.error(StateError('EventSource not started yet'));
    }

    late final StreamController<T> controller;
    void handler(html.Event e) {
      final me = e is html.MessageEvent ? e : null;
      final raw = me?.data?.toString();
      if (raw == null) return;
      try {
        controller.add(parser.parse(raw));
      } catch (err, st) {
        controller.addError(err, st);
      }
    }

    controller = StreamController<T>.broadcast(
      onListen: () {
        es.addEventListener(fieldKey, handler);
      },
      onCancel: () {
        es.removeEventListener(fieldKey, handler);
      },
    );

    Stream<T> out = controller.stream;
    if (distinct) out = out.distinct();
    return out;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;

    for (final s in _subscriptions) {
      await s.cancel();
    }
    _subscriptions.clear();

    _eventSource?.close();
    _eventSource = null;

    await _framesController.close();
  }
}
