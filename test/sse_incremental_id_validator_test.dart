import 'package:flutter_test/flutter_test.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/src/sse_frame.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/src/sse_incremental_id.dart';

void main() {
  SseFrame frameWithId(String id) => SseFrame.fromFields({
    'id': [id],
    'data': ['x'],
  });
  SseFrame frameWithoutId() => SseFrame.fromFields({
    'data': ['x'],
  });

  test(
    'missing id before initialization is ignored when requireFirstId=false',
    () {
      final v = SseIncrementalIdValidator();
      final mismatch = v.validate(frameWithoutId(), requireFirstId: false);
      expect(mismatch, isNull);
      expect(v.initialized, isFalse);
    },
  );

  test(
    'non-numeric id before initialization is mismatch (but does not initialize)',
    () {
      final v = SseIncrementalIdValidator();
      final mismatch = v.validate(frameWithId('abc'), requireFirstId: false);
      expect(mismatch, isNotNull);
      expect(mismatch!.reason, SseIncrementalIdMismatchReason.nonNumericId);
      expect(v.initialized, isFalse);
    },
  );

  test('valid increment passes', () {
    final v = SseIncrementalIdValidator();
    expect(v.validate(frameWithId('1'), requireFirstId: false), isNull);
    expect(v.validate(frameWithId('2'), requireFirstId: false), isNull);
    expect(v.lastId, 2);
  });

  test('unexpected id yields mismatch and resyncs', () {
    final v = SseIncrementalIdValidator();
    expect(v.validate(frameWithId('1'), requireFirstId: false), isNull);

    final mismatch = v.validate(frameWithId('4'), requireFirstId: false);
    expect(mismatch, isNotNull);
    expect(mismatch!.reason, SseIncrementalIdMismatchReason.unexpectedId);
    expect(mismatch.expectedId, 2);
    expect(v.lastId, 4);

    // Next expected is 5 after resync.
    expect(v.validate(frameWithId('5'), requireFirstId: false), isNull);
  });
}
