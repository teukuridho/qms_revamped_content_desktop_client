import 'package:openapi/api.dart';

abstract class RemoteProductRegistryClient {
  Future<List<ProductDto>> getMany({
    required Uri baseUri,
    required String accessToken,
    required String tag,
    int size = 9999,
  });
}

class OpenApiRemoteProductRegistryClient
    implements RemoteProductRegistryClient {
  @override
  Future<List<ProductDto>> getMany({
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

    final api = ProductRegistryApi(apiClient);
    final page = await api.getMany1(
      page: 0,
      size: size,
      sort: const ['position,asc'],
      tag: tag,
    );
    return page?.content ?? const <ProductDto>[];
  }
}
