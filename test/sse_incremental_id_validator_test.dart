import 'package:flutter_test/flutter_test.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/src/sse_frame.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/src/sse_incremental_id.dart';

void main() {
  SseFrame frameWithId(String id) => SseFrame.fromFields({'id': [id], 'data': ['x']});
  SseFrame frameWithoutId() => SseFrame.fromFields({'data': ['x']});

  test('first frame requires numeric id when enabled', () {
    final v = SseIncrementalIdValidator();
    final mismatch = v.validate(frameWithoutId(), requireFirstId: true);
    expect(mismatch, isNotNull);
    expect(mismatch!.reason, SseIncrementalIdMismatchReason.missingId);
    expect(v.initialized, isFalse);
  });

  test('first frame non-numeric id is mismatch', () {
    final v = SseIncrementalIdValidator();
    final mismatch = v.validate(frameWithId('abc'), requireFirstId: true);
    expect(mismatch, isNotNull);
    expect(mismatch!.reason, SseIncrementalIdMismatchReason.nonNumericId);
    expect(v.initialized, isFalse);
  });

  test('valid increment passes', () {
    final v = SseIncrementalIdValidator();
    expect(v.validate(frameWithId('1'), requireFirstId: true), isNull);
    expect(v.validate(frameWithId('2'), requireFirstId: true), isNull);
    expect(v.lastId, 2);
  });

  test('unexpected id yields mismatch and resyncs', () {
    final v = SseIncrementalIdValidator();
    expect(v.validate(frameWithId('1'), requireFirstId: true), isNull);

    final mismatch = v.validate(frameWithId('4'), requireFirstId: true);
    expect(mismatch, isNotNull);
    expect(mismatch!.reason, SseIncrementalIdMismatchReason.unexpectedId);
    expect(mismatch.expectedId, 2);
    expect(v.lastId, 4);

    // Next expected is 5 after resync.
    expect(v.validate(frameWithId('5'), requireFirstId: true), isNull);
  });
}

