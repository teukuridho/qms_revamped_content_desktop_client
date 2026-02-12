import 'sse_frame.dart';

/// Incremental parser for Server-Sent Events-like streams.
///
/// - Lines are `\n` separated (CRLF supported).
/// - Fields are `key: value` (single leading space in value is stripped).
/// - A blank line ends a frame.
/// - Lines beginning with `:` are treated as comments and ignored.
class SseParser {
  final StringBuffer _buf = StringBuffer();
  final Map<String, List<String>> _current = {};

  void reset() {
    _buf.clear();
    _current.clear();
  }

  List<SseFrame> add(String chunk) {
    _buf.write(chunk);
    final out = <SseFrame>[];

    var s = _buf.toString();
    int start = 0;

    for (int i = 0; i < s.length; i++) {
      if (s.codeUnitAt(i) != 0x0A /* \n */ ) continue;

      var line = s.substring(start, i);
      if (line.endsWith('\r')) {
        line = line.substring(0, line.length - 1);
      }
      start = i + 1;

      final frame = _consumeLine(line);
      if (frame != null) out.add(frame);
    }

    // Keep remainder.
    final remainder = s.substring(start);
    _buf
      ..clear()
      ..write(remainder);

    return out;
  }

  List<SseFrame> close() {
    final out = <SseFrame>[];
    final remaining = _buf.toString();
    if (remaining.isNotEmpty) {
      out.addAll(add('\n')); // Force flush line.
    }
    final frame = _endFrameIfNeeded();
    if (frame != null) out.add(frame);
    _buf.clear();
    return out;
  }

  SseFrame? _consumeLine(String line) {
    if (line.isEmpty) {
      return _endFrameIfNeeded();
    }
    if (line.startsWith(':')) {
      return null;
    }

    final idx = line.indexOf(':');
    String field;
    String value;
    if (idx == -1) {
      field = line;
      value = '';
    } else {
      field = line.substring(0, idx);
      value = line.substring(idx + 1);
      if (value.startsWith(' ')) {
        value = value.substring(1);
      }
    }

    (_current[field] ??= <String>[]).add(value);
    return null;
  }

  SseFrame? _endFrameIfNeeded() {
    if (_current.isEmpty) return null;
    final frame = SseFrame.fromFields(_current);
    _current.clear();
    return frame;
  }
}
