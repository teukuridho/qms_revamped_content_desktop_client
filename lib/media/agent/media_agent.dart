import 'dart:async';

import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/media_downloader.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_player_controller.dart';
import 'package:qms_revamped_content_desktop_client/media/position_update/media_position_update_listener.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/directory/media_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/media/synchronizer/media_synchronizer.dart';

class MediaAgent {
  static final AppLog _log = AppLog('media_agent');

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final MediaStorageDirectoryService _mediaStorageDirectoryService;
  final OidcAuthService _authService;
  final MediaDownloader _downloader;
  final MediaPlayerController _playerController;
  final MediaSynchronizer _synchronizer;
  final MediaPositionUpdateListener _positionUpdateListener;

  StreamSubscription<AuthLoggedInEvent>? _authSub;
  bool _disposed = false;

  Future<void>? _inFlightInit;

  MediaAgent({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required MediaStorageDirectoryService mediaStorageDirectoryService,
    required OidcAuthService authService,
    required MediaDownloader downloader,
    required MediaPlayerController playerController,
    required MediaSynchronizer synchronizer,
    required MediaPositionUpdateListener positionUpdateListener,
  }) : _eventManager = eventManager,
       _mediaStorageDirectoryService = mediaStorageDirectoryService,
       _authService = authService,
       _downloader = downloader,
       _playerController = playerController,
       _synchronizer = synchronizer,
       _positionUpdateListener = positionUpdateListener;

  MediaPlayerController get playerController => _playerController;

  Future<void> init() async {
    if (_disposed) throw StateError('MediaAgent is disposed');

    await _mediaStorageDirectoryService.init();
    await _playerController.init();
    _synchronizer.init();
    _positionUpdateListener.init();

    _authSub ??= _eventManager.listen<AuthLoggedInEvent>().listen(
      (event) {
        if (_disposed) return;
        if (event.serviceName != serviceName) return;
        _log.i(
          'AuthLoggedInEvent matched; initializing media (serviceName=$serviceName tag=$tag)',
        );
        // Background task; reinit is idempotent.
        unawaited(reinit(autoPlay: true, startSynchronizer: true));
      },
      onError: (Object e, StackTrace st) {
        _log.e('Auth listener error', error: e, stackTrace: st);
      },
    );

    final hasToken = await _authService.hasUsableAccessTokenNow();
    if (hasToken) {
      await reinit(autoPlay: true, startSynchronizer: true);
    }
  }

  Future<void> reinit({bool autoPlay = true, bool startSynchronizer = true}) {
    if (_disposed) return Future.value();

    final existing = _inFlightInit;
    if (existing != null) return existing;

    final f = _reinitInner(
      autoPlay: autoPlay,
      startSynchronizer: startSynchronizer,
    );
    _inFlightInit = f;
    return f.whenComplete(() => _inFlightInit = null);
  }

  Future<void> _reinitInner({
    required bool autoPlay,
    required bool startSynchronizer,
  }) async {
    _log.i(
      'reinit(startSynchronizer=$startSynchronizer autoPlay=$autoPlay serviceName=$serviceName tag=$tag)',
    );

    await _downloader.downloadAll();
    await _playerController.loadFromDatabase();

    if (startSynchronizer) {
      _synchronizer.start();
    }

    if (autoPlay) {
      await _playerController.play(reason: 'reinit');
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    await _authSub?.cancel();
    _authSub = null;

    await _synchronizer.dispose();
    await _positionUpdateListener.dispose();

    // ChangeNotifier dispose is sync; this is best-effort.
    // ignore: discarded_futures
    _playerController.disposeAsync();
  }
}
