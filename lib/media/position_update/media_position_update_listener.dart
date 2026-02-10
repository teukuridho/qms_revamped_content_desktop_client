import 'dart:async';

import 'package:openapi/api.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_player_controller.dart';

class MediaPositionUpdateListener {
  static final AppLog _log = AppLog('media_pos_listener');

  final String serviceName;
  final String tag;
  final EventManager _eventManager;
  final MediaPlayerController _playerController;

  StreamSubscription<PositionUpdatedEventDto>? _sub;

  MediaPositionUpdateListener({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required MediaPlayerController playerController,
  }) : _eventManager = eventManager,
       _playerController = playerController;

  void init() {
    _sub ??= _eventManager.listen<PositionUpdatedEventDto>().listen((dto) {
      final tableName = dto.tableName;
      final dtoTag = dto.tag;
      if (tableName != serviceName || dtoTag != tag) return;
      _log.i(
        'Position update received; marking reload needed (id=${dto.id} newPosition=${dto.newPosition})',
      );
      _playerController.markReloadNeeded();
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
