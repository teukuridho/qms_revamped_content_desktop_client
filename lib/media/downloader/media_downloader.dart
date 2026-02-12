import 'dart:async';
import 'dart:io';

import 'package:openapi/api.dart' show MediaDto;
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/event/media_download_events.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/media_downloader_logger.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/media_downloader_base.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/remote_media_registry_client.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/remote_media_storage_client.dart';
import 'package:qms_revamped_content_desktop_client/media/network/server_address_parser.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/service/media_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/service/media_storage_file_service.dart';

class MediaDownloader implements MediaDownloaderBase {
  final String serviceName;
  final String tag;

  final EventManager _eventManager;
  final ServerPropertiesRegistryService _serverPropertiesRegistryService;
  final OidcAuthService _authService;
  final MediaRegistryService _mediaRegistryService;
  final MediaStorageFileService _mediaStorageFileService;
  final RemoteMediaRegistryClient _remoteRegistryClient;
  final RemoteMediaStorageClient _remoteStorageClient;

  MediaDownloader({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    required MediaRegistryService mediaRegistryService,
    required MediaStorageFileService mediaStorageFileService,
    OidcAuthService? authService,
    RemoteMediaRegistryClient? remoteRegistryClient,
    RemoteMediaStorageClient? remoteStorageClient,
  }) : _eventManager = eventManager,
       _serverPropertiesRegistryService = serverPropertiesRegistryService,
       _authService =
           authService ??
           OidcAuthService(
             serviceName: serviceName,
             tag: tag,
             serverPropertiesRegistryService: serverPropertiesRegistryService,
           ),
       _mediaRegistryService = mediaRegistryService,
       _mediaStorageFileService = mediaStorageFileService,
       _remoteRegistryClient =
           remoteRegistryClient ?? OpenApiRemoteMediaRegistryClient(),
       _remoteStorageClient =
           remoteStorageClient ?? HttpRemoteMediaStorageClient();

  @override
  Future<int> downloadAll({int size = 9999}) async {
    _eventManager.publishEvent(
      MediaDownloadStartedEvent(serviceName: serviceName, tag: tag),
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

      MediaDownloaderLogger.info(
        'Downloading all media (serviceName=$serviceName tag=$tag base=$basePath)',
      );

      final remote = await _withValidAccessToken(
        operationName: 'media-registry getMany',
        run: (token) => _remoteRegistryClient.getMany(
          baseUri: basePath,
          accessToken: token,
          tag: tag,
          size: size,
        ),
      );

      final remoteIds = remote.map((e) => e.id).toSet();
      final local = await _mediaRegistryService.getAllByTagOrdered(tag: tag);
      for (final m in local) {
        if (!remoteIds.contains(m.remoteId)) {
          await _mediaStorageFileService.deleteIfExists(m.path);
          await _mediaRegistryService.delete(m.id);
        }
      }

      var downloaded = 0;
      for (final dto in remote) {
        if (dto.status.value.toUpperCase() == 'DELETED') {
          await _mediaRegistryService.deleteByRemoteId(
            remoteId: dto.id,
            tag: tag,
          );
          continue;
        }

        // Only download playable media.
        if (dto.status.value.toUpperCase() != 'READY') {
          continue;
        }

        downloaded += await _downloadAndUpsertOne(baseUri: basePath, dto: dto);
      }

      _eventManager.publishEvent(
        MediaDownloadSucceededEvent(
          serviceName: serviceName,
          tag: tag,
          downloadedCount: downloaded,
        ),
      );
      return downloaded;
    } catch (e, st) {
      MediaDownloaderLogger.error(
        'Download all failed (serviceName=$serviceName tag=$tag)',
        error: e,
        stackTrace: st,
      );
      _eventManager.publishEvent(
        MediaDownloadFailedEvent(
          serviceName: serviceName,
          tag: tag,
          message: e.toString(),
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> downloadOne(MediaDto dto) async {
    if (dto.status.value.toUpperCase() == 'DELETED') {
      await _mediaRegistryService.deleteByRemoteId(remoteId: dto.id, tag: tag);
      await _mediaStorageFileService.deleteIfExists(
        _mediaStorageFileService
            .fileFor(remoteId: dto.id, fileName: dto.fileName)
            .path,
      );
      return;
    }
    if (dto.status.value.toUpperCase() != 'READY') {
      return;
    }

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
    required MediaDto dto,
  }) async {
    if (dto.tag != tag) return 0;

    final localFile = _mediaStorageFileService.fileFor(
      remoteId: dto.id,
      fileName: dto.fileName,
    );

    final exists = await localFile.exists();
    if (!exists) {
      MediaDownloaderLogger.info(
        'Downloading media id=${dto.id} file=${localFile.path} tag=$tag',
      );
      await _withValidAccessToken(
        operationName: 'media-storage download',
        run: (token) => _remoteStorageClient.downloadToFile(
          baseUri: baseUri,
          accessToken: token,
          remoteId: dto.id,
          destination: localFile,
        ),
      );
      // Best-effort sanity check. The download endpoint should return bytes.
      if (!await localFile.exists()) {
        throw FileSystemException(
          'Download did not produce a file',
          localFile.path,
        );
      }
    } else {
      MediaDownloaderLogger.debug(
        'Skipping download; file exists: ${localFile.path}',
      );
    }

    await _mediaRegistryService.upsertByRemoteId(
      remoteId: dto.id,
      path: localFile.path,
      position: dto.position,
      contentType: dto.contentType.value,
      mimeType: dto.mimeType,
      tag: dto.tag,
    );

    return exists ? 0 : 1;
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

      MediaDownloaderLogger.warn(
        'Unauthorized during $operationName; forcing token refresh and retrying once (serviceName=$serviceName tag=$tag)',
      );
      final refreshed = await _authService.getValidAccessToken(
        forceRefresh: true,
      );
      final refreshedToken = refreshed?.trim() ?? '';
      if (refreshedToken.isEmpty) {
        MediaDownloaderLogger.error(
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
