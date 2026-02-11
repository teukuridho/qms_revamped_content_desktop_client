import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

class PositionUpdateSseIdMismatchEvent {
  final String serviceName;
  final String tag;
  final int occurredAtEpochMs;
  final SseIncrementalIdMismatch mismatch;

  PositionUpdateSseIdMismatchEvent({
    required this.serviceName,
    required this.tag,
    required this.occurredAtEpochMs,
    required this.mismatch,
  });
}

