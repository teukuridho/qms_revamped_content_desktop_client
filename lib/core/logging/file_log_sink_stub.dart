import 'log_record.dart';
import 'log_sink.dart';

/// No-op file sink for platforms without `dart:io` (web).
class FileLogSink implements LogSink {
  static Future<FileLogSink?> tryInit({String fileName = 'app.log'}) async {
    return null;
  }

  String get path => '';

  @override
  void write(LogRecord record) {}
}
