import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/position_update_subscriber.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_feature.dart';
import 'package:qms_revamped_content_desktop_client/media/player/ui/media_player_view.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/directory/media_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';

class MediaTestScreen extends StatelessWidget {
  static const String serviceName = 'main-media';
  static const String tag = 'main';

  const MediaTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MediaFeature>(
          create: (context) {
            final feature = MediaFeature.create(
              serviceName: serviceName,
              tag: tag,
              eventManager: context.read<EventManager>(),
              appDatabaseManager: context.read<AppDatabaseManager>(),
              serverPropertiesRegistryService: context
                  .read<ServerPropertiesRegistryService>(),
              mediaStorageDirectoryService: context
                  .read<MediaStorageDirectoryService>(),
            );
            // ignore: discarded_futures
            feature.agent.init();
            return feature;
          },
          dispose: (context, feature) {
            // ignore: discarded_futures
            feature.agent.dispose();
          },
        ),
        Provider<PositionUpdateSubscriber>(
          create: (context) => PositionUpdateSubscriber(
            serviceName: serviceName,
            tag: tag,
            sseIncrementalMismatchCallback: (_) {
              final feature = context.read<MediaFeature>();
              // ignore: discarded_futures
              feature.agent.reinit(autoPlay: true, startSynchronizer: true);
            },
            eventManager: context.read<EventManager>(),
            serverPropertiesRegistryService: context
                .read<ServerPropertiesRegistryService>(),
          )..init(),
          dispose: (context, subscriber) {
            // ignore: discarded_futures
            subscriber.dispose();
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final feature = context.read<MediaFeature>();
          return Scaffold(
            appBar: AppBar(title: const Text('Media Test')),
            body: MediaPlayerView(
              serviceName: serviceName,
              tag: tag,
              eventManager: context.read<EventManager>(),
              serverPropertiesRegistryService: context
                  .read<ServerPropertiesRegistryService>(),
              controller: feature.playerController,
              onReinitializeRequested: () async {
                await feature.agent.reinit(
                  autoPlay: true,
                  startSynchronizer: true,
                );
                await feature.playerController.playFromFirst(
                  reason: 'context_menu_reinitialize',
                );
              },
            ),
          );
        },
      ),
    );
  }
}
