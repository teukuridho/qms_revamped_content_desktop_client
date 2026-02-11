class AppConfig {
  // TODO: Replace with environment/config driven value when multiple services are supported.
  static const String serviceName = 'test';

  // Position update subscriber tag.
  static const String positionUpdateTag = 'main';

  // Main content feature wiring.
  static const String mediaServiceName = 'media';
  static const String mediaTag = 'main';
  static const String currencyExchangeRateServiceName =
      'currency_exchange_rate';
  static const String currencyExchangeRateTag = 'main';
}
