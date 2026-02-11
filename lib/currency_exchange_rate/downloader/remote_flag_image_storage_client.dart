import 'dart:io';

import 'package:http/http.dart' as http;

class RemoteFlagImageDownload {
  final List<int> bytes;
  final String mimeType;

  const RemoteFlagImageDownload({required this.bytes, required this.mimeType});
}

abstract class RemoteFlagImageStorageClient {
  Future<RemoteFlagImageDownload> download({
    required Uri baseUri,
    required String accessToken,
    required int remoteId,
  });
}

class HttpRemoteFlagImageStorageClient implements RemoteFlagImageStorageClient {
  final http.Client _client;

  HttpRemoteFlagImageStorageClient({http.Client? client})
    : _client = client ?? http.Client();

  @override
  Future<RemoteFlagImageDownload> download({
    required Uri baseUri,
    required String accessToken,
    required int remoteId,
  }) async {
    final uri = baseUri.replace(
      pathSegments: <String>[
        ...baseUri.pathSegments.where((e) => e.isNotEmpty),
        'flag-image-storage',
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
        'Flag image download failed ($remoteId): HTTP ${resp.statusCode} $body',
        uri: uri,
      );
    }

    final bytes = await resp.stream.toBytes();
    final mimeType =
        resp.headers['content-type']?.split(';').first.trim() ??
        'application/octet-stream';
    return RemoteFlagImageDownload(bytes: bytes, mimeType: mimeType);
  }
}
