import 'package:openapi/api.dart' show ProductDto;
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/product/downloader/event/product_download_events.dart';
import 'package:qms_revamped_content_desktop_client/product/downloader/product_downloader_base.dart';
import 'package:qms_revamped_content_desktop_client/product/downloader/remote_product_registry_client.dart';
import 'package:qms_revamped_content_desktop_client/product/network/server_address_parser.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/service/product_registry_service.dart';

class ProductDownloader implements ProductDownloaderBase {
  static final AppLog _log = AppLog('product_downloader');

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final ServerPropertiesRegistryService _serverPropertiesRegistryService;
  final OidcAuthService _authService;
  final ProductRegistryService _registryService;
  final RemoteProductRegistryClient _remoteRegistryClient;

  ProductDownloader({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    required ProductRegistryService registryService,
    OidcAuthService? authService,
    RemoteProductRegistryClient? remoteRegistryClient,
  }) : _eventManager = eventManager,
       _serverPropertiesRegistryService = serverPropertiesRegistryService,
       _authService =
           authService ??
           OidcAuthService(
             serviceName: serviceName,
             tag: tag,
             serverPropertiesRegistryService: serverPropertiesRegistryService,
           ),
       _registryService = registryService,
       _remoteRegistryClient =
           remoteRegistryClient ?? OpenApiRemoteProductRegistryClient();

  @override
  Future<int> downloadAll({int size = 9999}) async {
    _eventManager.publishEvent(
      ProductDownloadStartedEvent(serviceName: serviceName, tag: tag),
    );

    try {
      final sp = await _serverPropertiesRegistryService
          .getOneByServiceNameAndTag(serviceName: serviceName, tag: tag);
      if (sp == null) {
        throw StateError(
          'Missing server properties for serviceName=$serviceName',
        );
      }

      final serverAddress = sp.serverAddress.trim();
      if (serverAddress.isEmpty) {
        throw StateError('Missing serverAddress for serviceName=$serviceName');
      }

      final baseUri = ServerAddressParser.parse(serverAddress);
      final basePath = Uri.parse(
        ServerAddressParser.normalizeBasePath(baseUri),
      );

      _log.i(
        'Downloading all products (serviceName=$serviceName tag=$tag base=$basePath)',
      );

      final remote = await _withValidAccessToken(
        operationName: 'product-registry getMany',
        run: (token) => _remoteRegistryClient.getMany(
          baseUri: basePath,
          accessToken: token,
          tag: tag,
          size: size,
        ),
      );

      final remoteIds = remote.map((e) => e.id).toSet();
      final local = await _registryService.getAllByTagOrdered(tag: tag);
      for (final row in local) {
        if (remoteIds.contains(row.remoteId)) continue;
        await _registryService.delete(row.id);
      }

      var synced = 0;
      for (final dto in remote) {
        synced += await _downloadAndUpsertOne(dto: dto);
      }

      _eventManager.publishEvent(
        ProductDownloadSucceededEvent(
          serviceName: serviceName,
          tag: tag,
          syncedCount: synced,
        ),
      );
      return synced;
    } catch (e, st) {
      _log.e(
        'Download all failed (serviceName=$serviceName tag=$tag)',
        error: e,
        stackTrace: st,
      );
      _eventManager.publishEvent(
        ProductDownloadFailedEvent(
          serviceName: serviceName,
          tag: tag,
          message: e.toString(),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> downloadOne(ProductDto dto) async {
    if (dto.tag != tag) return;
    await _downloadAndUpsertOne(dto: dto);
  }

  Future<int> _downloadAndUpsertOne({required ProductDto dto}) async {
    if (dto.tag != tag) return 0;

    await _registryService.upsertByRemoteId(
      remoteId: dto.id,
      name: dto.name,
      value: dto.value,
      position: dto.position,
      tag: dto.tag,
    );

    return 1;
  }

  Future<T> _withValidAccessToken<T>({
    required String operationName,
    required Future<T> Function(String accessToken) run,
  }) async {
    final token = await _authService.getValidAccessToken();
    final accessToken = token?.trim() ?? '';
    if (accessToken.isEmpty) {
      throw StateError(
        'Missing/expired access token for serviceName=$serviceName (login first)',
      );
    }

    try {
      return await run(accessToken);
    } catch (e, st) {
      if (!_isUnauthorizedError(e)) rethrow;

      _log.w(
        'Unauthorized during $operationName; forcing token refresh and retrying once',
      );
      final refreshed = await _authService.getValidAccessToken(
        forceRefresh: true,
      );
      final refreshedToken = refreshed?.trim() ?? '';
      if (refreshedToken.isEmpty) {
        _log.e(
          'Forced token refresh failed during $operationName',
          error: e,
          stackTrace: st,
        );
        rethrow;
      }
      return run(refreshedToken);
    }
  }

  bool _isUnauthorizedError(Object error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('401') || msg.contains('unauthorized');
  }
}
