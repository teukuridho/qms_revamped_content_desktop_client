import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/product/agent/product_agent.dart';
import 'package:qms_revamped_content_desktop_client/product/downloader/product_downloader.dart';
import 'package:qms_revamped_content_desktop_client/product/position_update/product_position_update_listener.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/service/product_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/product/storage/service/product_deleter.dart';
import 'package:qms_revamped_content_desktop_client/product/synchronizer/product_synchronizer.dart';

class ProductFeature {
  final ProductRegistryService registryService;
  final ProductDownloader downloader;
  final ProductDeleter deleter;
  final ProductSynchronizer synchronizer;
  final ProductPositionUpdateListener positionUpdateListener;
  final ProductAgent agent;

  ProductFeature._({
    required this.registryService,
    required this.downloader,
    required this.deleter,
    required this.synchronizer,
    required this.positionUpdateListener,
    required this.agent,
  });

  factory ProductFeature.create({
    required String serviceName,
    required String tag,
    required EventManager eventManager,
    required AppDatabaseManager appDatabaseManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
  }) {
    final registryService = ProductRegistryService(
      appDatabaseManager: appDatabaseManager,
      eventManager: eventManager,
    );

    final downloader = ProductDownloader(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      registryService: registryService,
    );

    final deleter = ProductDeleter(tag: tag, registryService: registryService);

    final synchronizer = ProductSynchronizer(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
      downloader: downloader,
      deleter: deleter,
    );

    final positionUpdateListener = ProductPositionUpdateListener(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      registryService: registryService,
    );

    final authService = OidcAuthService(
      serviceName: serviceName,
      tag: tag,
      serverPropertiesRegistryService: serverPropertiesRegistryService,
    );

    final agent = ProductAgent(
      serviceName: serviceName,
      tag: tag,
      eventManager: eventManager,
      authService: authService,
      downloader: downloader,
      synchronizer: synchronizer,
      positionUpdateListener: positionUpdateListener,
    );

    return ProductFeature._(
      registryService: registryService,
      downloader: downloader,
      deleter: deleter,
      synchronizer: synchronizer,
      positionUpdateListener: positionUpdateListener,
      agent: agent,
    );
  }
}
