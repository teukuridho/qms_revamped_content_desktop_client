import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

abstract class RemoteMediaStorageClient {
  Future<void> downloadToFile({
    required Uri baseUri,
    required String accessToken,
    required int remoteId,
    required File destination,
  });
}

class HttpRemoteMediaStorageClient implements RemoteMediaStorageClient {
  static final AppLog _log = AppLog('remote_media_storage');

  final http.Client _client;

  HttpRemoteMediaStorageClient({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<void> downloadToFile({
    required Uri baseUri,
    required String accessToken,
    required int remoteId,
    required File destination,
  }) async {
    final uri = baseUri.replace(
      pathSegments: <String>[
        ...baseUri.pathSegments.where((e) => e.isNotEmpty),
        'media-storage',
        '$remoteId',
        'download',
      ],
    );

    final req = http.Request('GET', uri);
    if (accessToken.trim().isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $accessToken';
    }

    final resp = await _client.send(req);
    if (resp.statusCode >= 400) {
      final body = await resp.stream.bytesToString();
      throw HttpException(
        'Download failed ($remoteId): HTTP ${resp.statusCode} $body',
        uri: uri,
      );
    }

    await destination.parent.create(recursive: true);

    // Use a unique .part file name to avoid collisions when multiple downloads
    // attempt to write the same destination concurrently (common on desktop with
    // SSE + periodic refresh).
    final tmp = File(
      '${destination.path}.part.${DateTime.now().microsecondsSinceEpoch}',
    );

    try {
      final sink = tmp.openWrite();
      try {
        await resp.stream.pipe(sink);
      } finally {
        await sink.flush();
        await sink.close();
      }

      await _replaceFileWithRetries(tmp: tmp, destination: destination);
    } catch (e, st) {
      _log.e(
        'downloadToFile failed (remoteId=$remoteId uri=$uri dest=${destination.path} '
        'destLen=${destination.path.length} tmp=${tmp.path} tmpLen=${tmp.path.length} '
        'destExists=${await destination.exists()} tmpExists=${await tmp.exists()})',
        error: e,
        stackTrace: st,
      );
      // Best-effort cleanup; leaving .part files behind is confusing.
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      rethrow;
    }
  }

  static Future<void> _replaceFileWithRetries({
    required File tmp,
    required File destination,
  }) async {
    // Ensure destination isn't present, then rename .part into place. On Windows
    // this can fail transiently due to AV/indexing or another reader briefly
    // holding a handle; so we retry and fall back to copy+delete.
    if (await destination.exists()) {
      await destination.delete();
    }

    final delays = <Duration>[
      Duration.zero,
      const Duration(milliseconds: 40),
      const Duration(milliseconds: 80),
      const Duration(milliseconds: 160),
      const Duration(milliseconds: 320),
      const Duration(milliseconds: 640),
      const Duration(milliseconds: 1000),
    ];

    FileSystemException? lastFs;
    for (final d in delays) {
      if (d != Duration.zero) {
        await Future<void>.delayed(d);
      }
      try {
        await tmp.rename(destination.path);
        return;
      } on FileSystemException catch (e) {
        lastFs = e;
      }
    }

    // Fallback: copy into place and delete tmp.
    try {
      if (await destination.exists()) {
        await destination.delete();
      }
      await tmp.copy(destination.path);
      await tmp.delete();
      return;
    } catch (e) {
      if (lastFs != null) {
        // Preserve the more informative original rename failure.
        throw lastFs;
      }
      rethrow;
    }
  }
}
