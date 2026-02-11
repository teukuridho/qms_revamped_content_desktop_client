import 'package:openapi/api.dart';

abstract class RemoteCurrencyExchangeRateRegistryClient {
  Future<List<CurrencyExchangeRateDto>> getMany({
    required Uri baseUri,
    required String accessToken,
    required String tag,
    int size = 9999,
  });
}

class OpenApiRemoteCurrencyExchangeRateRegistryClient
    implements RemoteCurrencyExchangeRateRegistryClient {
  @override
  Future<List<CurrencyExchangeRateDto>> getMany({
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

    final api = CurrencyExchangeRateRegistryApi(apiClient);
    final page = await api.getManyCurrencyExchangeRates(
      page: 0,
      size: size,
      sort: const ['position,asc'],
      tag: tag,
    );
    return page?.content ?? const <CurrencyExchangeRateDto>[];
  }
}
