import 'dart:convert';

abstract class SseValueParser<T> {
  const SseValueParser();
  T parse(String raw);
}

class SseStringParser extends SseValueParser<String> {
  const SseStringParser();

  @override
  String parse(String raw) => raw;
}

class SseJsonParser extends SseValueParser<Object?> {
  const SseJsonParser();

  @override
  Object? parse(String raw) {
    if (raw.isEmpty) return null;
    return jsonDecode(raw);
  }
}
