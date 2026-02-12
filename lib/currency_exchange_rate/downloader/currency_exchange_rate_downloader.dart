import 'dart:async';

import 'package:openapi/api.dart' show CurrencyExchangeRateDto;
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/currency_exchange_rate_downloader_base.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/event/currency_exchange_rate_download_events.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/remote_currency_exchange_rate_registry_client.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/downloader/remote_flag_image_storage_client.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/network/server_address_parser.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/service/currency_exchange_rate_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/storage/service/currency_exchange_rate_flag_storage_file_service.dart';

class CurrencyExchangeRateDownloader
    implements CurrencyExchangeRateDownloaderBase {
  static final AppLog _log = AppLog('currency_exchange_rate_downloader');

  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final ServerPropertiesRegistryService _serverPropertiesRegistryService;
  final OidcAuthService _authService;
  final CurrencyExchangeRateRegistryService _registryService;
  final CurrencyExchangeRateFlagStorageFileService _flagStorageFileService;
  final RemoteCurrencyExchangeRateRegistryClient _remoteRegistryClient;
  final RemoteFlagImageStorageClient _remoteFlagStorageClient;

  CurrencyExchangeRateDownloader({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    required CurrencyExchangeRateRegistryService registryService,
    required CurrencyExchangeRateFlagStorageFileService flagStorageFileService,
    OidcAuthService? authService,
    RemoteCurrencyExchangeRateRegistryClient? remoteRegistryClient,
    RemoteFlagImageStorageClient? remoteFlagStorageClient,
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
       _flagStorageFileService = flagStorageFileService,
       _remoteRegistryClient =
           remoteRegistryClient ??
           OpenApiRemoteCurrencyExchangeRateRegistryClient(),
       _remoteFlagStorageClient =
           remoteFlagStorageClient ?? HttpRemoteFlagImageStorageClient();

  @override
  Future<int> downloadAll({int size = 9999}) async {
    _eventManager.publishEvent(
      CurrencyExchangeRateDownloadStartedEvent(
        serviceName: serviceName,
        tag: tag,
      ),
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
        'Downloading all currency exchange rates (serviceName=$serviceName tag=$tag base=$basePath)',
      );

      final remote = await _withValidAccessToken(
        operationName: 'currency-exchange-rate-registry getMany',
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
        final path = row.flagImagePath;
        if (path != null && path.isNotEmpty) {
          await _flagStorageFileService.deleteIfExists(path);
        }
        await _registryService.delete(row.id);
      }

      var synced = 0;
      for (final dto in remote) {
        synced += await _downloadAndUpsertOne(baseUri: basePath, dto: dto);
      }

      _eventManager.publishEvent(
        CurrencyExchangeRateDownloadSucceededEvent(
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
        CurrencyExchangeRateDownloadFailedEvent(
          serviceName: serviceName,
          tag: tag,
          message: e.toString(),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> downloadOne(CurrencyExchangeRateDto dto) async {
    if (dto.tag != tag) return;

    final sp = await _serverPropertiesRegistryService.getOneByServiceNameAndTag(
      serviceName: serviceName,
      tag: tag,
    );
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
    final basePath = Uri.parse(ServerAddressParser.normalizeBasePath(baseUri));
    await _downloadAndUpsertOne(baseUri: basePath, dto: dto);
  }

  Future<int> _downloadAndUpsertOne({
    required Uri baseUri,
    required CurrencyExchangeRateDto dto,
  }) async {
    if (dto.tag != tag) return 0;

    final existing = await _registryService.getOneByRemoteId(
      remoteId: dto.id,
      tag: tag,
    );

    String? flagImagePath;
    final remoteFlagImageId = dto.flagImageId;

    if (remoteFlagImageId == null) {
      final oldPath = existing?.flagImagePath;
      if (oldPath != null && oldPath.isNotEmpty) {
        await _flagStorageFileService.deleteIfExists(oldPath);
      }
    } else {
      final oldId = existing?.flagImageId;
      final oldPath = existing?.flagImagePath;
      final hasReusableLocalFile =
          oldId == remoteFlagImageId &&
          oldPath != null &&
          oldPath.isNotEmpty &&
          await _flagStorageFileService.exists(oldPath);

      if (hasReusableLocalFile) {
        flagImagePath = oldPath;
      } else {
        final download = await _withValidAccessToken(
          operationName: 'flag-image-storage download',
          run: (token) => _remoteFlagStorageClient.download(
            baseUri: baseUri,
            accessToken: token,
            remoteId: remoteFlagImageId,
          ),
        );

        flagImagePath = await _flagStorageFileService.writeFlagImage(
          remoteFlagImageId: remoteFlagImageId,
          bytes: download.bytes,
          mimeType: download.mimeType,
        );

        if (oldPath != null && oldPath.isNotEmpty && oldPath != flagImagePath) {
          await _flagStorageFileService.deleteIfExists(oldPath);
        }
      }
    }

    await _registryService.upsertByRemoteId(
      remoteId: dto.id,
      flagImageId: remoteFlagImageId,
      flagImagePath: flagImagePath,
      countryName: dto.currencyName,
      currencyCode: dto.currencyCode,
      buy: dto.buy ?? 0.0,
      sell: dto.sell ?? 0.0,
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
