class MediaPlayEvent {
  final String serviceName;
  final String tag;
  final String reason;

  const MediaPlayEvent({
    required this.serviceName,
    required this.tag,
    this.reason = '',
  });
}
