import 'dart:async';

import 'package:openapi/api.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

import 'position_update_subscriber_logger.dart';

typedef SseClientFactory = SseClientBase Function(SseClientOptions options);

/// Subscribes to `/position-updated-subscribe` using SSE when an auth login event is received.
///
/// Emits `PositionUpdatedEventDto` via [EventManager] for matching `tableName` and `tag`.
class PositionUpdateSubscriber {
  static Duration retryDelay = const Duration(seconds: 3);
  static const String sseFieldKey = 'position-updated';

  final String serviceName;
  final String tag;
  final SseIncrementalMismatchCallback sseIncrementalMismatchCallback;

  final EventManager _eventManager;
  final ServerPropertiesRegistryService _serverPropertiesRegistryService;
  final SseClientFactory _sseClientFactory;

  StreamSubscription<AuthLoggedInEvent>? _authSub;
  SseClientBase? _sseClient;

  bool _disposed = false;
  int _generation = 0;

  PositionUpdateSubscriber({
    required this.serviceName,
    required this.tag,
    required this.sseIncrementalMismatchCallback,
    required EventManager eventManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    SseClientFactory? sseClientFactory,
  })  : _eventManager = eventManager,
        _serverPropertiesRegistryService = serverPropertiesRegistryService,
        _sseClientFactory = sseClientFactory ?? ((options) => SseClient(options));

  void init() {
    if (_disposed) {
      throw StateError('PositionUpdateSubscriber is disposed');
    }

    _authSub ??= _eventManager.listen<AuthLoggedInEvent>().listen(
          _onAuthLoggedInEvent,
          onError: (Object e, StackTrace st) {
            PositionUpdateSubscriberLogger.error(
              'Auth listener error (serviceName=$serviceName tag=$tag)',
              error: e,
              stackTrace: st,
            );
          },
        );
  }

  void _onAuthLoggedInEvent(AuthLoggedInEvent event) {
    if (_disposed) return;
    if (event.serviceName != serviceName) return;

    PositionUpdateSubscriberLogger.info(
      'AuthLoggedInEvent matched. Starting SSE subscribe loop (serviceName=$serviceName tag=$tag)',
    );
    _startSubscribeLoop();
  }

  void _startSubscribeLoop() {
    _generation += 1;
    final gen = _generation;

    // Background task; it will stop itself on dispose or when superseded.
    unawaited(_runSubscribeLoop(gen));
  }

  Future<void> _runSubscribeLoop(int gen) async {
    await _closeSseClient();

    while (!_disposed && gen == _generation) {
      try {
        await _subscribeOnce(gen);

        // If we return normally, the SSE stream ended. Treat it as a reconnect
        // condition and retry after delay.
        if (_disposed || gen != _generation) break;
        PositionUpdateSubscriberLogger.warn(
          'SSE stream ended; retrying in ${retryDelay.inSeconds}s (serviceName=$serviceName tag=$tag)',
        );
      } catch (e, st) {
        PositionUpdateSubscriberLogger.error(
          'Subscribe failed; retrying in ${retryDelay.inSeconds}s (serviceName=$serviceName tag=$tag)',
          error: e,
          stackTrace: st,
        );
      } finally {
        await _closeSseClient();
      }

      if (_disposed || gen != _generation) break;
      await Future<void>.delayed(retryDelay);
    }
  }

  Future<void> _subscribeOnce(int gen) async {
    final sp = await _serverPropertiesRegistryService.getOneByServiceName(
      serviceName: serviceName,
    );
    if (sp == null) {
      throw StateError('Missing server properties for serviceName=$serviceName');
    }

    final serverAddress = sp.serverAddress.trim();
    if (serverAddress.isEmpty) {
      throw StateError('Missing serverAddress for serviceName=$serviceName');
    }

    final token = sp.oidcAccessToken.trim();
    if (token.isEmpty) {
      throw StateError(
        'Missing access token for serviceName=$serviceName (login first)',
      );
    }

    final baseUri = _parseServerAddress(serverAddress);
    final subscribeUri = _buildSubscribeUri(baseUri);

    PositionUpdateSubscriberLogger.info(
      'Subscribing SSE: $subscribeUri (serviceName=$serviceName tag=$tag)',
    );

    final client = _sseClientFactory(
      SseClientOptions(
        url: subscribeUri,
        headers: {
          'Authorization': 'Bearer $token',
        },
        enableSseIncrementalIdMismatch: true,
        shouldRefreshWhenIdMismatch: true,
        sseIncrementalMismatchCallback: (mismatch) {
          PositionUpdateSubscriberLogger.warn(
            'SSE incremental id mismatch (serviceName=$serviceName tag=$tag): $mismatch',
          );
          sseIncrementalMismatchCallback(mismatch);
        },
      ),
    );
    _sseClient = client;

    await client.start();

    await for (final raw in client.listenJson(sseFieldKey)) {
      if (_disposed || gen != _generation) break;

      PositionUpdatedEventDto? dto;
      try {
        dto = PositionUpdatedEventDto.fromJson(raw);
      } catch (e, st) {
        PositionUpdateSubscriberLogger.warn(
          'Ignoring invalid SSE payload (not PositionUpdatedEventDto): $raw',
        );
        PositionUpdateSubscriberLogger.error(
          'PositionUpdatedEventDto parse error',
          error: e,
          stackTrace: st,
        );
        continue;
      }

      if (dto == null) {
        PositionUpdateSubscriberLogger.warn(
          'Ignoring SSE payload (expected object): $raw',
        );
        continue;
      }

      final tableName = dto.tableName;
      final dtoTag = dto.tag;
      if (tableName != serviceName || dtoTag != tag) {
        continue;
      }

      PositionUpdateSubscriberLogger.info(
        'Position updated event received; publishing (serviceName=$serviceName tag=$tag id=${dto.id} newPosition=${dto.newPosition})',
      );
      _eventManager.publishEvent(dto);
    }
  }

  Uri _buildSubscribeUri(Uri baseUri) {
    final segments = <String>[
      ...baseUri.pathSegments.where((e) => e.isNotEmpty),
      'position-updated-subscribe',
    ];

    return baseUri.replace(
      pathSegments: segments,
      queryParameters: <String, String>{
        'tableName': serviceName,
        'tag': tag,
      },
    );
  }

  static Uri _parseServerAddress(String serverAddress) {
    final raw = serverAddress.trim();
    if (raw.isEmpty) {
      throw const FormatException('serverAddress is empty');
    }

    // Most common config is a full URL. If the scheme is missing, try http://.
    if (!raw.contains('://')) {
      final fixed = 'http://$raw';
      final uri = Uri.parse(fixed);
      if (uri.host.isEmpty) {
        throw FormatException('Invalid serverAddress: $serverAddress');
      }
      return uri;
    }

    final uri = Uri.parse(raw);
    if (uri.host.isEmpty) {
      throw FormatException('Invalid serverAddress: $serverAddress');
    }
    return uri;
  }

  Future<void> _closeSseClient() async {
    final client = _sseClient;
    _sseClient = null;
    if (client != null) {
      try {
        await client.close();
      } catch (e, st) {
        PositionUpdateSubscriberLogger.error(
          'Error closing SSE client (serviceName=$serviceName tag=$tag)',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _authSub?.cancel();
    _authSub = null;

    await _closeSseClient();
  }
}
