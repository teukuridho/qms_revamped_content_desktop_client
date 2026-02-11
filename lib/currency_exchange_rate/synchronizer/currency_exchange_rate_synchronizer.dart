import 'dart:async';

import 'package:openapi/api.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/currency_exchange_rate_downloader_base.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/network/server_address_parser.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/service/currency_exchange_rate_deleter_base.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

import 'currency_exchange_rate_synchronizer_logger.dart';

typedef SseClientFactory = SseClientBase Function(SseClientOptions options);

class CurrencyExchangeRateSynchronizer {
  static Duration retryDelay = const Duration(seconds: 3);
  static Duration weakSseIdRefreshCooldown = const Duration(seconds: 30);

  static const String createdFieldKey = 'created';
  static const String updatedFieldKey = 'updated';
  static const String deletedFieldKey = 'deleted';

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final ServerPropertiesRegistryService _serverPropertiesRegistryService;
  final OidcAuthService _authService;
  final CurrencyExchangeRateDownloaderBase _downloader;
  final CurrencyExchangeRateDeleterBase _deleter;
  final Future<void> Function(SseIncrementalIdMismatch mismatch)?
  _sseIncrementalMismatchCallback;
  final SseClientFactory _sseClientFactory;

  StreamSubscription<AuthLoggedInEvent>? _authSub;
  SseClientBase? _sseClient;

  bool _disposed = false;
  int _generation = 0;
  bool _fullRefreshInFlight = false;
  DateTime? _lastWeakSseIdRefreshAt;

  CurrencyExchangeRateSynchronizer({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    required CurrencyExchangeRateDownloaderBase downloader,
    required CurrencyExchangeRateDeleterBase deleter,
    Future<void> Function(SseIncrementalIdMismatch mismatch)?
    sseIncrementalMismatchCallback,
    OidcAuthService? authService,
    SseClientFactory? sseClientFactory,
  }) : _eventManager = eventManager,
       _serverPropertiesRegistryService = serverPropertiesRegistryService,
       _authService =
           authService ??
           OidcAuthService(
             serviceName: serviceName,
             serverPropertiesRegistryService: serverPropertiesRegistryService,
           ),
       _downloader = downloader,
       _deleter = deleter,
       _sseIncrementalMismatchCallback = sseIncrementalMismatchCallback,
       _sseClientFactory =
           sseClientFactory ?? ((options) => SseClient(options));

  void init() {
    if (_disposed) {
      throw StateError('CurrencyExchangeRateSynchronizer is disposed');
    }

    _authSub ??= _eventManager.listen<AuthLoggedInEvent>().listen(
      _onAuthLoggedInEvent,
      onError: (Object e, StackTrace st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Auth listener error (serviceName=$serviceName tag=$tag)',
          error: e,
          stackTrace: st,
        );
      },
    );
  }

  void start() {
    if (_disposed) return;
    _startSubscribeLoop();
  }

  void _onAuthLoggedInEvent(AuthLoggedInEvent event) {
    if (_disposed) return;
    if (event.serviceName != serviceName) return;
    CurrencyExchangeRateSynchronizerLogger.info(
      'AuthLoggedInEvent matched. Starting currency exchange rate SSE subscribe loop (serviceName=$serviceName tag=$tag)',
    );
    _startSubscribeLoop();
  }

  void _startSubscribeLoop() {
    _generation += 1;
    final gen = _generation;
    unawaited(_runSubscribeLoop(gen));
  }

  Future<void> _runSubscribeLoop(int gen) async {
    await _closeSseClient();

    while (!_disposed && gen == _generation) {
      try {
        await _subscribeOnce(gen);
        if (_disposed || gen != _generation) break;
        CurrencyExchangeRateSynchronizerLogger.warn(
          'Currency exchange rate SSE stream ended; retrying in ${retryDelay.inSeconds}s (serviceName=$serviceName tag=$tag)',
        );
      } catch (e, st) {
        if (_isUnauthorizedError(e)) {
          try {
            await _authService.getValidAccessToken(forceRefresh: true);
          } catch (_) {
            // Best-effort; retry loop continues.
          }
        }
        CurrencyExchangeRateSynchronizerLogger.error(
          'Currency exchange rate subscribe failed; retrying in ${retryDelay.inSeconds}s (serviceName=$serviceName tag=$tag)',
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
      throw StateError(
        'Missing server properties for serviceName=$serviceName',
      );
    }

    final serverAddress = sp.serverAddress.trim();
    if (serverAddress.isEmpty) {
      throw StateError('Missing serverAddress for serviceName=$serviceName');
    }

    final token = (await _authService.getValidAccessToken())?.trim() ?? '';
    if (token.isEmpty) {
      throw StateError(
        'Missing/expired access token for serviceName=$serviceName (login first)',
      );
    }

    final baseUri = ServerAddressParser.parse(serverAddress);
    final subscribeUri = _buildSubscribeUri(baseUri);

    CurrencyExchangeRateSynchronizerLogger.info(
      'Subscribing currency exchange rate SSE: $subscribeUri (serviceName=$serviceName tag=$tag)',
    );

    var seenConnectedLog = false;
    final client = _sseClientFactory(
      SseClientOptions(
        url: subscribeUri,
        headers: {'Authorization': 'Bearer $token'},
        logger: (level, message, {error, stackTrace}) {
          final prefix =
              'SSE(currency-exchange-rate serviceName=$serviceName tag=$tag)';
          switch (level) {
            case SseClientLogLevel.debug:
              CurrencyExchangeRateSynchronizerLogger.debug('$prefix $message');
              break;
            case SseClientLogLevel.info:
              CurrencyExchangeRateSynchronizerLogger.info('$prefix $message');
              break;
            case SseClientLogLevel.warn:
              CurrencyExchangeRateSynchronizerLogger.warn('$prefix $message');
              break;
            case SseClientLogLevel.error:
              CurrencyExchangeRateSynchronizerLogger.error(
                '$prefix $message',
                error: error,
                stackTrace: stackTrace,
              );
              break;
          }

          if (level == SseClientLogLevel.info &&
              message.startsWith('connected(')) {
            if (seenConnectedLog) {
              CurrencyExchangeRateSynchronizerLogger.warn(
                'Currency exchange rate SSE reconnected; forcing full refresh '
                '(serviceName=$serviceName tag=$tag)',
              );
              unawaited(_refreshFromBackend(reason: 'sse_reconnected'));
            }
            seenConnectedLog = true;
          }
        },
        enableSseIncrementalIdMismatch: true,
        shouldRefreshWhenIdMismatch: true,
        sseIncrementalMismatchCallback: (mismatch) {
          CurrencyExchangeRateSynchronizerLogger.warn(
            'Currency exchange rate SSE incremental id mismatch (serviceName=$serviceName tag=$tag): $mismatch',
          );
          unawaited(_handleSseIncrementalMismatch(mismatch));
        },
      ),
    );

    _sseClient = client;
    await client.start();

    final f1 = _processCreated(gen, client);
    final f2 = _processUpdated(gen, client);
    final f3 = _processDeleted(gen, client);
    final f4 = _monitorCrudFrameIdHealth(gen, client);

    // Keep CRUD listeners attached before first full refresh, so events are not
    // dropped during initial downloadAll().
    await _refreshFromBackend(reason: 'sse_connected');
    await Future.any([f1, f2, f3, f4]);
  }

  Future<void> _processCreated(int gen, SseClientBase client) async {
    await for (final raw in client.listenJson(createdFieldKey)) {
      if (_disposed || gen != _generation) break;
      CurrencyExchangeRateSynchronizerLogger.debug('Created raw payload: $raw');

      CurrencyExchangeRateCreatedEventDto? dto;
      try {
        dto = CurrencyExchangeRateCreatedEventDto.fromJson(raw);
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Ignoring invalid created payload: $raw',
          error: e,
          stackTrace: st,
        );
        continue;
      }

      final currencyExchangeRate = dto?.currencyExchangeRate;
      if (currencyExchangeRate == null) continue;
      if (currencyExchangeRate.tag != tag) continue;

      CurrencyExchangeRateSynchronizerLogger.info(
        'Created event received; syncing remoteId=${currencyExchangeRate.id} tag=$tag',
      );
      try {
        await _downloader.downloadOne(currencyExchangeRate);
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Failed syncing created remoteId=${currencyExchangeRate.id}',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  Future<void> _processUpdated(int gen, SseClientBase client) async {
    await for (final raw in client.listenJson(updatedFieldKey)) {
      if (_disposed || gen != _generation) break;
      CurrencyExchangeRateSynchronizerLogger.debug('Updated raw payload: $raw');

      CurrencyExchangeRateUpdatedEventDto? dto;
      try {
        dto = CurrencyExchangeRateUpdatedEventDto.fromJson(raw);
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Ignoring invalid updated payload: $raw',
          error: e,
          stackTrace: st,
        );
        continue;
      }

      final currencyExchangeRate = dto?.currencyExchangeRate;
      if (currencyExchangeRate == null) continue;
      if (currencyExchangeRate.tag != tag) continue;

      CurrencyExchangeRateSynchronizerLogger.info(
        'Updated event received; syncing remoteId=${currencyExchangeRate.id} tag=$tag',
      );
      try {
        await _downloader.downloadOne(currencyExchangeRate);
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Failed syncing updated remoteId=${currencyExchangeRate.id}',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  Future<void> _processDeleted(int gen, SseClientBase client) async {
    await for (final raw in client.listenJson(deletedFieldKey)) {
      if (_disposed || gen != _generation) break;
      CurrencyExchangeRateSynchronizerLogger.debug('Deleted raw payload: $raw');

      CurrencyExchangeRateDeletedEventDto? dto;
      try {
        dto = CurrencyExchangeRateDeletedEventDto.fromJson(raw);
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Ignoring invalid deleted payload: $raw',
          error: e,
          stackTrace: st,
        );
        continue;
      }

      final remoteId = dto?.id;
      if (remoteId == null) continue;
      CurrencyExchangeRateSynchronizerLogger.info(
        'Deleted event received; deleting remoteId=$remoteId tag=$tag',
      );

      try {
        await _deleter.deleteLocalByRemoteId(remoteId);
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Failed deleting remoteId=$remoteId',
          error: e,
          stackTrace: st,
        );
      }
    }
  }

  Future<void> _monitorCrudFrameIdHealth(int gen, SseClientBase client) async {
    int? lastNumericId;
    await for (final frame in client.frames) {
      if (_disposed || gen != _generation) break;
      if (!_isCrudFrame(frame)) continue;

      final rawId = frame.id;
      final parsedId = (rawId == null || rawId.isEmpty)
          ? null
          : int.tryParse(rawId);
      if (parsedId == null) {
        _scheduleWeakSseIdRefresh(
          reason: 'sse_id_missing_or_non_numeric',
          details: 'rawId=$rawId',
        );
        continue;
      }

      if (lastNumericId != null && parsedId != (lastNumericId + 1)) {
        _scheduleWeakSseIdRefresh(
          reason: 'sse_id_non_incremental',
          details: 'expected=${lastNumericId + 1} actual=$parsedId',
        );
      }
      lastNumericId = parsedId;
    }
  }

  bool _isCrudFrame(SseFrame frame) {
    final event = frame.event;
    if (event == createdFieldKey ||
        event == updatedFieldKey ||
        event == deletedFieldKey) {
      return true;
    }

    return frame.fields.containsKey(createdFieldKey) ||
        frame.fields.containsKey(updatedFieldKey) ||
        frame.fields.containsKey(deletedFieldKey);
  }

  void _scheduleWeakSseIdRefresh({
    required String reason,
    required String details,
  }) {
    final now = DateTime.now();
    final last = _lastWeakSseIdRefreshAt;
    if (last != null && now.difference(last) < weakSseIdRefreshCooldown) {
      return;
    }
    _lastWeakSseIdRefreshAt = now;

    CurrencyExchangeRateSynchronizerLogger.warn(
      'Weak SSE id health detected; forcing full refresh '
      '(serviceName=$serviceName tag=$tag reason=$reason details=$details)',
    );
    unawaited(_refreshFromBackend(reason: reason));
  }

  Uri _buildSubscribeUri(Uri baseUri) {
    final segments = <String>[
      ...baseUri.pathSegments.where((e) => e.isNotEmpty),
      'currency-exchange-rate-subscribe',
    ];

    // Backend contract for currency CRUD events uses this endpoint directly.
    // DTO payloads are parsed from created/updated/deleted SSE fields.
    return baseUri.replace(pathSegments: segments);
  }

  Future<void> _closeSseClient() async {
    final client = _sseClient;
    _sseClient = null;
    if (client != null) {
      try {
        await client.close();
      } catch (e, st) {
        CurrencyExchangeRateSynchronizerLogger.error(
          'Error closing currency exchange rate SSE client (serviceName=$serviceName tag=$tag)',
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

  Future<void> _handleSseIncrementalMismatch(
    SseIncrementalIdMismatch mismatch,
  ) async {
    if (_disposed) return;

    final callback = _sseIncrementalMismatchCallback;
    if (callback != null) {
      await callback(mismatch);
      return;
    }

    await _refreshFromBackend(reason: 'sse_incremental_id_mismatch');
  }

  Future<void> _refreshFromBackend({required String reason}) async {
    if (_disposed || _fullRefreshInFlight) return;
    _fullRefreshInFlight = true;

    try {
      CurrencyExchangeRateSynchronizerLogger.warn(
        'Refreshing currency exchange rates from backend due to $reason (serviceName=$serviceName tag=$tag)',
      );
      await _downloader.downloadAll();
    } catch (e, st) {
      CurrencyExchangeRateSynchronizerLogger.error(
        'Full refresh failed after $reason (serviceName=$serviceName tag=$tag)',
        error: e,
        stackTrace: st,
      );
    } finally {
      _fullRefreshInFlight = false;
    }
  }

  bool _isUnauthorizedError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('401') || msg.contains('unauthorized');
  }
}
