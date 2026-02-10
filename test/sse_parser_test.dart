import 'package:flutter_test/flutter_test.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/src/sse_parser.dart';

void main() {
  test('parses single data frame', () {
    final p = SseParser();
    final frames = p.add('data: hello\n\n');
    expect(frames, hasLength(1));
    expect(frames.single.data, 'hello');
  });

  test('parses multi-line data joined with newline', () {
    final p = SseParser();
    final frames = p.add('data: a\ndata: b\n\n');
    expect(frames, hasLength(1));
    expect(frames.single.data, 'a\nb');
  });

  test('parses custom field keys', () {
    final p = SseParser();
    final frames = p.add('position-updated: {"x":1}\n\n');
    expect(frames, hasLength(1));
    expect(frames.single.fieldValue('position-updated'), '{"x":1}');
  });

  test('ignores comment lines', () {
    final p = SseParser();
    final frames = p.add(':keep-alive\ndata: ok\n\n');
    expect(frames, hasLength(1));
    expect(frames.single.data, 'ok');
  });

  test('supports CRLF', () {
    final p = SseParser();
    final frames = p.add('data: hi\r\n\r\n');
    expect(frames, hasLength(1));
    expect(frames.single.data, 'hi');
  });

  test('flushes trailing frame on close', () {
    final p = SseParser();
    expect(p.add('data: partial'), isEmpty);
    final frames = p.close();
    expect(frames, hasLength(1));
    expect(frames.single.data, 'partial');
  });
}
