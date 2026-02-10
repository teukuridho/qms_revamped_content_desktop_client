class MediaStopEvent {
  final String serviceName;
  final String tag;
  final String reason;

  const MediaStopEvent({
    required this.serviceName,
    required this.tag,
    this.reason = '',
  });
}
