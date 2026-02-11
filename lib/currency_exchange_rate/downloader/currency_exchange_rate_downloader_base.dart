import 'package:openapi/api.dart' show CurrencyExchangeRateDto;

abstract class CurrencyExchangeRateDownloaderBase {
  Future<int> downloadAll({int size = 9999});

  Future<void> downloadOne(CurrencyExchangeRateDto dto);
}
