class CreateMediaRequest {
  late final int remoteId;
  late final String path;
  late final int position;
  late final String contentType;
  late final String mimeType;
  late final String tag;

  CreateMediaRequest({
    required this.remoteId,
    required this.path,
    required this.position,
    required this.contentType,
    required this.mimeType,
    required this.tag,
  });
}
