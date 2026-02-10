import 'dart:async';

import 'sse_frame.dart';
import 'sse_value_parser.dart';

class SseClientOptions {
  final Uri url;

  /// Extra request headers (Authorization, etc).
  final Map<String, String> headers;

  /// Convenience cookie map. Will be merged into the `Cookie` header if set.
  final Map<String, String> cookies;

  /// Auto reconnect if the connection drops.
  final bool autoReconnect;

  /// Base delay between reconnect attempts.
  final Duration reconnectDelay;

  /// Maximum reconnect attempts. `null` means infinite retries.
  final int? maxReconnectAttempts;

  /// Connection timeout. `null` means no timeout (SSE connections are long-lived).
  final Duration? connectTimeout;

  /// Initial `Last-Event-ID` value to send when connecting (IO only).
  ///
  /// If the server sends `id:` fields, the client will automatically keep this
  /// value updated and re-send it on reconnect (unless disabled).
  final String? initialLastEventId;

  /// Whether to send the last received event id as `Last-Event-ID` header on connect/reconnect (IO only).
  final bool sendLastEventIdHeader;

  /// Header name used for last event id (IO only).
  final String lastEventIdHeaderName;

  const SseClientOptions({
    required this.url,
    this.headers = const {},
    this.cookies = const {},
    this.autoReconnect = true,
    this.reconnectDelay = const Duration(seconds: 2),
    this.maxReconnectAttempts,
    this.connectTimeout,
    this.initialLastEventId,
    this.sendLastEventIdHeader = true,
    this.lastEventIdHeaderName = 'Last-Event-ID',
  });
}

abstract class SseClientBase {
  SseClientOptions get options;

  /// All parsed frames (each blank-line-delimited block).
  Stream<SseFrame> get frames;

  bool get isRunning;

  /// Starts the SSE connection. Calling multiple times is safe.
  Future<void> start();

  /// Closes the SSE connection and releases resources.
  Future<void> close();

  /// Listen to a specific field key and parse values.
  ///
  /// Matching rules:
  /// - If the server sends a line like `<fieldKey>: <value>`, that value is used.
  /// - Otherwise, if the server uses standard SSE (`event: <fieldKey>` + `data: ...`),
  ///   `data` is used.
  ///
  /// Set [distinct] to drop duplicate consecutive values.
  Stream<T> listen<T>(
    String fieldKey, {
    required SseValueParser<T> parser,
    bool distinct = false,
  });
}

extension SseClientConvenience on SseClientBase {
  Stream<String> listenString(
    String fieldKey, {
    bool distinct = false,
  }) =>
      listen<String>(fieldKey, parser: const SseStringParser(), distinct: distinct);

  Stream<Object?> listenJson(
    String fieldKey, {
    bool distinct = false,
  }) =>
      listen<Object?>(fieldKey, parser: const SseJsonParser(), distinct: distinct);
}
