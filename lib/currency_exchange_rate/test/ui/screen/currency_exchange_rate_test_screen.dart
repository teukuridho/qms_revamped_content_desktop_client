import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/config/app_config.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/position_update_subscriber.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/agent/currency_exchange_rate_feature.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/directory/currency_exchange_rate_flag_storage_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/view/currency_exchange_rate_table_view.dart';

class CurrencyExchangeRateTestScreen extends StatelessWidget {
  static const String serviceName = AppConfig.currencyExchangeRateServiceName;
  static const String tag = AppConfig.currencyExchangeRateTag;

  const CurrencyExchangeRateTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CurrencyExchangeRateFeature>(
          create: (context) {
            final feature = CurrencyExchangeRateFeature.create(
              serviceName: serviceName,
              tag: tag,
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
            serviceName: serviceName,
            tag: tag,
            // CurrencyExchangeRateAgent handles PositionUpdateSseIdMismatchEvent.
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
          final feature = context.read<CurrencyExchangeRateFeature>();
          return Scaffold(
            appBar: AppBar(title: const Text('Currency Exchange Rate Test')),
            body: CurrencyExchangeRateTableView(
              serviceName: serviceName,
              tag: tag,
              eventManager: context.read<EventManager>(),
              serverPropertiesRegistryService: context
                  .read<ServerPropertiesRegistryService>(),
              registryService: feature.registryService,
              onReinitializeRequested: () async {
                await feature.agent.reinit(startSynchronizer: true);
              },
            ),
          );
        },
      ),
    );
  }
}
