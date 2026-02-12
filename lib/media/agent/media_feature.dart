import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_agent.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/media_downloader.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_player_controller.dart';
import 'package:qms_revamped_content_desktop_client/media/position_update/media_mass_position_updated_event_listener.dart';
import 'package:qms_revamped_content_desktop_client/media/position_update/media_position_update_listener.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/service/media_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/directory/media_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/service/media_deleter.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/service/media_storage_file_service.dart';
import 'package:qms_revamped_content_desktop_client/media/synchronizer/media_synchronizer.dart';

/// Convenience wiring for screens that want to embed the media player while
/// keeping dependencies explicitly injected.
class MediaFeature {
  final MediaRegistryService registryService;
  final MediaStorageFileService storageFileService;
  final MediaPlayerController playerController;
  final MediaDownloader downloader;
  final MediaDeleter deleter;
  final MediaSynchronizer synchronizer;
  final MediaPositionUpdateListener positionUpdateListener;
  final MediaMassPositionUpdatedEventListener massPositionUpdatedEventListener;
  final MediaAgent agent;

  MediaFeature._({
    required this.registryService,
    required this.storageFileService,
    required this.playerController,
    required this.downloader,
    required this.deleter,
    required this.synchronizer,
    required this.positionUpdateListener,
    required this.massPositionUpdatedEventListener,
    required this.agent,
  });

  factory MediaFeature.create({
    required String serviceName,
    required String tag,
    required EventManager eventManager,
    required AppDatabaseManager appDatabaseManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    required MediaStorageDirectoryService mediaStorageDirectoryService,
  }) {
    final registryService = MediaRegistryService(
      appDatabaseManager: appDatabaseManager,
      eventManager: eventManager,
    );

    final storageFileService = MediaStorageFileService(
      directoryService: mediaStorageDirectoryService,
    );

    final playerController = MediaPlayerController(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      mediaRegistryService: registryService,
    );

    final downloader = MediaDownloader(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      mediaRegistryService: registryService,
      mediaStorageFileService: storageFileService,
    );

    final deleter = MediaDeleter(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      playerController: playerController,
      mediaRegistryService: registryService,
      mediaStorageFileService: storageFileService,
    );

    final synchronizer = MediaSynchronizer(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      downloader: downloader,
      deleter: deleter,
      playerController: playerController,
    );

    final positionUpdateListener = MediaPositionUpdateListener(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      mediaRegistryService: registryService,
    );

    final massPositionUpdatedEventListener =
        MediaMassPositionUpdatedEventListener(
          serviceName: serviceName,
          tag: tag,
          eventManager: eventManager,
          reloadSignal: playerController,
        );

    final authService = OidcAuthService(
      serviceName: serviceName,
      tag: tag,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      // No EventManager required; this is used only for token checks/refresh.
    );

    final agent = MediaAgent(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      mediaStorageDirectoryService: mediaStorageDirectoryService,
      authService: authService,
      downloader: downloader,
      playerController: playerController,
      synchronizer: synchronizer,
      positionUpdateListener: positionUpdateListener,
      massPositionUpdatedEventListener: massPositionUpdatedEventListener,
    );

    return MediaFeature._(
      registryService: registryService,
      storageFileService: storageFileService,
      playerController: playerController,
      downloader: downloader,
      deleter: deleter,
      synchronizer: synchronizer,
      positionUpdateListener: positionUpdateListener,
      massPositionUpdatedEventListener: massPositionUpdatedEventListener,
      agent: agent,
    );
  }
}
