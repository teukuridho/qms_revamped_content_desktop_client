import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

abstract class RemoteMediaStorageClient {
  Future<void> downloadToFile({
    required Uri baseUri,
    required String accessToken,
    required int remoteId,
    required File destination,
  });
}

class HttpRemoteMediaStorageClient implements RemoteMediaStorageClient {
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
    final tmp = File('${destination.path}.part');
    final sink = tmp.openWrite();
    try {
      await resp.stream.pipe(sink);
    } finally {
      await sink.flush();
      await sink.close();
    }

    if (await destination.exists()) {
      await destination.delete();
    }
    await tmp.rename(destination.path);
  }
}
