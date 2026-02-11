class CurrencyExchangeRateDownloadStartedEvent {
  final String serviceName;
  final String tag;

  const CurrencyExchangeRateDownloadStartedEvent({
    required this.serviceName,
    required this.tag,
  });
}

class CurrencyExchangeRateDownloadSucceededEvent {
  final String serviceName;
  final String tag;
  final int syncedCount;

  const CurrencyExchangeRateDownloadSucceededEvent({
    required this.serviceName,
    required this.tag,
    required this.syncedCount,
  });
}

class CurrencyExchangeRateDownloadFailedEvent {
  final String serviceName;
  final String tag;
  final String message;

  const CurrencyExchangeRateDownloadFailedEvent({
    required this.serviceName,
    required this.tag,
    required this.message,
  });
}
