import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/config/app_config.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/position_update_subscriber.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/product/agent/product_feature.dart';
import 'package:qms_revamped_content_desktop_client/product/view/product_table_view.dart';

class ProductTestScreen extends StatelessWidget {
  static const String serviceName = AppConfig.productServiceName;
  static const String tag = AppConfig.productTag;

  const ProductTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ProductFeature>(
          create: (context) {
            final feature = ProductFeature.create(
              serviceName: serviceName,
              tag: tag,
              eventManager: context.read<EventManager>(),
              appDatabaseManager: context.read<AppDatabaseManager>(),
              serverPropertiesRegistryService: context
                  .read<ServerPropertiesRegistryService>(),
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
            // ProductAgent handles PositionUpdateSseIdMismatchEvent.
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
          final feature = context.read<ProductFeature>();
          return Scaffold(
            appBar: AppBar(title: const Text('Product Test')),
            body: ProductTableView(
              serviceName: serviceName,
              tag: tag,
              nameHeader: 'DEPOSITO RP',
              valueHeader: 'Suk Bunga(%p.a)',
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
