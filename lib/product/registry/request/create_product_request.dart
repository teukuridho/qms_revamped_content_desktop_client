class CreateProductRequest {
  late final int remoteId;
  late final String name;
  late final String value;
  late final int position;
  late final String tag;

  CreateProductRequest({
    required this.remoteId,
    required this.name,
    required this.value,
    required this.position,
    required this.tag,
  });
}
