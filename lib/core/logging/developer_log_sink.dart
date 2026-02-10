import 'dart:developer' as dev;

import 'log_level.dart';
import 'log_record.dart';
import 'log_sink.dart';

class DeveloperLogSink implements LogSink {
  const DeveloperLogSink();

  @override
  void write(LogRecord record) {
    dev.log(
      record.message,
      name: record.logger,
      level: record.level.developerLevel,
      error: record.error,
      stackTrace: record.stackTrace,
      time: record.timestamp,
    );
  }
}
