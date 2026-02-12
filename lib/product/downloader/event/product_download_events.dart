class ProductDownloadStartedEvent {
  final String serviceName;
  final String tag;

  const ProductDownloadStartedEvent({
    required this.serviceName,
    required this.tag,
  });
}

class ProductDownloadSucceededEvent {
  final String serviceName;
  final String tag;
  final int syncedCount;

  const ProductDownloadSucceededEvent({
    required this.serviceName,
    required this.tag,
    required this.syncedCount,
  });
}

class ProductDownloadFailedEvent {
  final String serviceName;
  final String tag;
  final String message;

  const ProductDownloadFailedEvent({
    required this.serviceName,
    required this.tag,
    required this.message,
  });
}
