import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_player_controller.dart';
import 'package:qms_revamped_content_desktop_client/media/player/event/media_play_event.dart';
import 'package:qms_revamped_content_desktop_client/media/player/event/media_stop_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/service/media_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/service/media_deleter_base.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/service/media_storage_file_service.dart';

class MediaDeleter implements MediaDeleterBase {
  static final AppLog _log = AppLog('media_deleter');

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final MediaPlayerController _playerController;
  final MediaRegistryService _mediaRegistryService;
  final MediaStorageFileService _mediaStorageFileService;

  MediaDeleter({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required MediaPlayerController playerController,
    required MediaRegistryService mediaRegistryService,
    required MediaStorageFileService mediaStorageFileService,
  }) : _eventManager = eventManager,
       _playerController = playerController,
       _mediaRegistryService = mediaRegistryService,
       _mediaStorageFileService = mediaStorageFileService;

  Future<void> deleteLocalByRemoteId(int remoteId) async {
    final existing = await _mediaRegistryService.getOneByRemoteId(
      remoteId: remoteId,
      tag: tag,
    );
    if (existing == null) return;
    await deleteLocalById(existing.id);
  }

  Future<void> deleteLocalById(int localId) async {
    await _playerController.goToLastAndStop();
    _eventManager.publishEvent(
      MediaStopEvent(serviceName: serviceName, tag: tag, reason: 'deleting'),
    );

    final dbRow = await _mediaRegistryService.getOneById(id: localId);
    if (dbRow == null) return;
    if (dbRow.tag != tag) return;

    _log.i(
      'Deleting media localId=$localId remoteId=${dbRow.remoteId} path=${dbRow.path}',
    );
    await _mediaStorageFileService.deleteIfExists(dbRow.path);
    await _mediaRegistryService.delete(localId);

    _playerController.markReloadNeeded();
    _eventManager.publishEvent(
      MediaPlayEvent(serviceName: serviceName, tag: tag, reason: 'deleted'),
    );
  }
}
