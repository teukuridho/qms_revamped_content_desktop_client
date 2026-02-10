import 'package:openapi/api.dart';

abstract class RemoteMediaRegistryClient {
  Future<List<MediaDto>> getMany({
    required Uri baseUri,
    required String accessToken,
    required String tag,
    int size = 9999,
  });
}

class OpenApiRemoteMediaRegistryClient implements RemoteMediaRegistryClient {
  @override
  Future<List<MediaDto>> getMany({
    required Uri baseUri,
    required String accessToken,
    required String tag,
    int size = 9999,
  }) async {
    final auth = HttpBearerAuth()..accessToken = accessToken;
    final apiClient = ApiClient(
      basePath: baseUri.toString(),
      authentication: auth,
    );

    final api = MediaRegistryApi(apiClient);
    final page = await api.getMany2(
      page: 0,
      size: size,
      sort: const ['position,asc'],
      tag: tag,
    );
    return page?.content ?? const <MediaDto>[];
  }
}
