import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/position_update_subscriber.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/agent/currency_exchange_rate_feature.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/directory/currency_exchange_rate_flag_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/view/currency_exchange_rate_table_view.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_feature.dart';
import 'package:qms_revamped_content_desktop_client/media/player/ui/media_player_view.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/directory/media_storage_directory_service.dart';

class MainScreen extends StatelessWidget {
  static const String mediaServiceName = 'main-media';
  static const String mediaTag = 'main';
  static const String currencyServiceName = 'main-currency-exchange-rate';
  static const String currencyTag = 'main';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<MediaFeature>(
          create: (context) {
            final feature = MediaFeature.create(
              serviceName: mediaServiceName,
              tag: mediaTag,
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
        Provider<CurrencyExchangeRateFeature>(
          create: (context) {
            final feature = CurrencyExchangeRateFeature.create(
              serviceName: currencyServiceName,
              tag: currencyTag,
              eventManager: context.read<EventManager>(),
              appDatabaseManager: context.read<AppDatabaseManager>(),
              serverPropertiesRegistryService: context
                  .read<ServerPropertiesRegistryService>(),
              flagStorageDirectoryService: context
                  .read<CurrencyExchangeRateFlagStorageDirectoryService>(),
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
            serviceName: mediaServiceName,
            tag: mediaTag,
            sseIncrementalMismatchCallback: (_) {},
            eventManager: context.read<EventManager>(),
            serverPropertiesRegistryService: context
                .read<ServerPropertiesRegistryService>(),
          )..init(),
          dispose: (context, subscriber) {
            // ignore: discarded_futures
            subscriber.dispose();
          },
        ),
        Provider<PositionUpdateSubscriber>(
          create: (context) => PositionUpdateSubscriber(
            serviceName: currencyServiceName,
            tag: currencyTag,
            sseIncrementalMismatchCallback: (_) {},
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
          final mediaFeature = context.read<MediaFeature>();
          final currencyFeature = context.read<CurrencyExchangeRateFeature>();

          return Scaffold(
            appBar: AppBar(title: const Text('Main Content')),
            body: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: MediaPlayerView(
                    serviceName: mediaServiceName,
                    tag: mediaTag,
                    eventManager: context.read<EventManager>(),
                    serverPropertiesRegistryService: context
                        .read<ServerPropertiesRegistryService>(),
                    controller: mediaFeature.playerController,
                    onReinitializeRequested: () async {
                      await mediaFeature.agent.reinit(
                        autoPlay: true,
                        startSynchronizer: true,
                      );
                      await mediaFeature.playerController.playFromFirst(
                        reason: 'main_screen_reinitialize_media',
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  flex: 3,
                  child: CurrencyExchangeRateTableView(
                    serviceName: currencyServiceName,
                    tag: currencyTag,
                    eventManager: context.read<EventManager>(),
                    serverPropertiesRegistryService: context
                        .read<ServerPropertiesRegistryService>(),
                    registryService: currencyFeature.registryService,
                    onReinitializeRequested: () async {
                      await currencyFeature.agent.reinit(
                        startSynchronizer: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
