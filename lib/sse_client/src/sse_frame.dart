class SseFrame {
  /// Raw, per-line fields.
  /// Values preserve ordering; multi-line fields become a list.
  final Map<String, List<String>> fields;

  const SseFrame(this.fields);

  factory SseFrame.fromFields(Map<String, List<String>> fields) =>
      SseFrame(Map<String, List<String>>.unmodifiable(fields));

  /// Returns the field value joined by `\n` (SSE semantics for multi-line `data:`).
  String? fieldValue(String key) {
    final list = fields[key];
    if (list == null || list.isEmpty) return null;
    return list.join('\n');
  }

  String? get data => fieldValue('data');
  String? get event => fieldValue('event');
  String? get id => fieldValue('id');
  String? get retry => fieldValue('retry');

  @override
  String toString() => 'SseFrame($fields)';
}
