import 'dart:async';

import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/event/position_update_sse_id_mismatch_event.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/currency_exchange_rate_downloader.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/position_update/currency_exchange_rate_position_update_listener.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/directory/currency_exchange_rate_flag_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/synchronizer/currency_exchange_rate_synchronizer.dart';

class CurrencyExchangeRateAgent {
  static final AppLog _log = AppLog('currency_exchange_rate_agent');

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final CurrencyExchangeRateFlagStorageDirectoryService _directoryService;
  final OidcAuthService _authService;
  final CurrencyExchangeRateDownloader _downloader;
  final CurrencyExchangeRateSynchronizer _synchronizer;
  final CurrencyExchangeRatePositionUpdateListener _positionUpdateListener;

  StreamSubscription<AuthLoggedInEvent>? _authSub;
  StreamSubscription<PositionUpdateSseIdMismatchEvent>? _positionMismatchSub;
  bool _disposed = false;
  Future<void>? _inFlightInit;

  CurrencyExchangeRateAgent({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required CurrencyExchangeRateFlagStorageDirectoryService directoryService,
    required OidcAuthService authService,
    required CurrencyExchangeRateDownloader downloader,
    required CurrencyExchangeRateSynchronizer synchronizer,
    required CurrencyExchangeRatePositionUpdateListener positionUpdateListener,
  }) : _eventManager = eventManager,
       _directoryService = directoryService,
       _authService = authService,
       _downloader = downloader,
       _synchronizer = synchronizer,
       _positionUpdateListener = positionUpdateListener;

  Future<void> init() async {
    if (_disposed) throw StateError('CurrencyExchangeRateAgent is disposed');

    await _directoryService.init();
    _synchronizer.init();
    _positionUpdateListener.init();

    _authSub ??= _eventManager.listen<AuthLoggedInEvent>().listen(
      (event) {
        if (_disposed) return;
        if (event.serviceName != serviceName || event.tag != tag) return;
        _log.i(
          'AuthLoggedInEvent matched; initializing currency exchange rates (serviceName=$serviceName tag=$tag)',
        );
        unawaited(reinit(startSynchronizer: true));
      },
      onError: (Object e, StackTrace st) {
        _log.e('Auth listener error', error: e, stackTrace: st);
      },
    );

    _positionMismatchSub ??= _eventManager
        .listen<PositionUpdateSseIdMismatchEvent>()
        .listen(
          (event) {
            if (_disposed) return;
            if (event.serviceName != serviceName || event.tag != tag) return;
            _log.w(
              'Position SSE mismatch received; reloading currency exchange rates from backend (serviceName=$serviceName tag=$tag mismatch=${event.mismatch})',
            );
            unawaited(reinit(startSynchronizer: false));
          },
          onError: (Object e, StackTrace st) {
            _log.e(
              'Position mismatch listener error',
              error: e,
              stackTrace: st,
            );
          },
        );

    final hasToken = await _authService.hasUsableAccessTokenNow();
    if (hasToken) {
      await reinit(startSynchronizer: true);
    }
  }

  Future<void> reinit({bool startSynchronizer = true}) {
    if (_disposed) return Future.value();

    final existing = _inFlightInit;
    if (existing != null) return existing;

    final f = _reinitInner(startSynchronizer: startSynchronizer);
    _inFlightInit = f;
    return f.whenComplete(() => _inFlightInit = null);
  }

  Future<void> _reinitInner({required bool startSynchronizer}) async {
    _log.i(
      'reinit(startSynchronizer=$startSynchronizer serviceName=$serviceName tag=$tag)',
    );
    await _downloader.downloadAll();
    if (startSynchronizer) {
      _synchronizer.start();
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _authSub?.cancel();
    _authSub = null;
    await _positionMismatchSub?.cancel();
    _positionMismatchSub = null;

    await _synchronizer.dispose();
    await _positionUpdateListener.dispose();
  }
}
