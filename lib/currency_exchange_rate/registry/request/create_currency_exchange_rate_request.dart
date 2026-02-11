class CreateCurrencyExchangeRateRequest {
  late final int remoteId;
  late final int? flagImageId;
  late final String? flagImagePath;
  late final String countryName;
  late final String currencyCode;
  late final int buy;
  late final int sell;
  late final int position;
  late final String tag;

  CreateCurrencyExchangeRateRequest({
    required this.remoteId,
    required this.flagImageId,
    required this.flagImagePath,
    required this.countryName,
    required this.currencyCode,
    required this.buy,
    required this.sell,
    required this.position,
    required this.tag,
  });
}
