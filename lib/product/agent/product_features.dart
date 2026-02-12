import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/product/agent/product_feature.dart';

class ProductFeatures {
  final ProductFeature main;
  final ProductFeature second;

  const ProductFeatures({required this.main, required this.second});

  factory ProductFeatures.create({
    required String serviceName,
    required String mainTag,
    required String secondTag,
    required EventManager eventManager,
    required AppDatabaseManager appDatabaseManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
  }) {
    return ProductFeatures(
      main: ProductFeature.create(
        serviceName: serviceName,
        tag: mainTag,
        eventManager: eventManager,
        appDatabaseManager: appDatabaseManager,
        serverPropertiesRegistryService: serverPropertiesRegistryService,
      ),
      second: ProductFeature.create(
        serviceName: serviceName,
        tag: secondTag,
        eventManager: eventManager,
        appDatabaseManager: appDatabaseManager,
        serverPropertiesRegistryService: serverPropertiesRegistryService,
      ),
    );
  }

  Iterable<ProductFeature> get all => [main, second];
}
