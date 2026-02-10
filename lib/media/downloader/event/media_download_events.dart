class MediaDownloadStartedEvent {
  final String serviceName;
  final String tag;

  const MediaDownloadStartedEvent({
    required this.serviceName,
    required this.tag,
  });
}

class MediaDownloadSucceededEvent {
  final String serviceName;
  final String tag;
  final int downloadedCount;

  const MediaDownloadSucceededEvent({
    required this.serviceName,
    required this.tag,
    required this.downloadedCount,
  });
}

class MediaDownloadFailedEvent {
  final String serviceName;
  final String tag;
  final String message;

  const MediaDownloadFailedEvent({
    required this.serviceName,
    required this.tag,
    required this.message,
  });
}
