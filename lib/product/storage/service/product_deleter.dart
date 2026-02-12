import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/service/product_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/product/storage/service/product_deleter_base.dart';

class ProductDeleter implements ProductDeleterBase {
  static final AppLog _log = AppLog('product_deleter');

  final String tag;
  final ProductRegistryService _registryService;

  ProductDeleter({
    required this.tag,
    required ProductRegistryService registryService,
  }) : _registryService = registryService;

  @override
  Future<void> deleteLocalByRemoteId(int remoteId) async {
    _log.i('deleteLocalByRemoteId(remoteId=$remoteId tag=$tag)');
    await _registryService.deleteByRemoteId(remoteId: remoteId, tag: tag);
  }
}
