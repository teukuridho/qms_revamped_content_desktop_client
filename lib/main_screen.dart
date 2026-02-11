import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/config/app_config.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/agent/currency_exchange_rate_feature.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/view/currency_exchange_rate_table_view.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_feature.dart';
import 'package:qms_revamped_content_desktop_client/media/player/ui/media_player_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaFeature = context.read<MediaFeature>();
    final currencyFeature = context.read<CurrencyExchangeRateFeature>();

    return Scaffold(
      appBar: AppBar(title: const Text('Main Content')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MediaPlayerView(
              serviceName: AppConfig.mediaServiceName,
              tag: AppConfig.mediaTag,
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
              serviceName: AppConfig.currencyExchangeRateServiceName,
              tag: AppConfig.currencyExchangeRateTag,
              eventManager: context.read<EventManager>(),
              serverPropertiesRegistryService: context
                  .read<ServerPropertiesRegistryService>(),
              registryService: currencyFeature.registryService,
              onReinitializeRequested: () async {
                await currencyFeature.agent.reinit(startSynchronizer: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
