import 'package:flutter/foundation.dart';

import 'developer_log_sink.dart';
import 'file_log_sink_stub.dart' if (dart.library.io) 'file_log_sink.dart';
import 'log_level.dart';
import 'log_record.dart';
import 'log_redactor.dart';
import 'log_sink.dart';

class AppLogConfig {
  static LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static bool redactSecrets = true;
  static final List<LogSink> sinks = <LogSink>[const DeveloperLogSink()];

  static Future<String?> enableFileLogging() async {
    // Web returns null via the stub implementation.
    final sink = await FileLogSink.tryInit();
    if (sink != null) {
      sinks.add(sink);
      return sink.path;
    }
    return null;
  }
}

class AppLog {
  final String name;

  const AppLog(this.name);

  static const AppLog root = AppLog('app');

  AppLog child(String suffix) => AppLog('$name.$suffix');

  void t(String message) => _emit(LogLevel.trace, message);
  void d(String message) => _emit(LogLevel.debug, message);
  void i(String message) => _emit(LogLevel.info, message);
  void w(String message) => _emit(LogLevel.warn, message);

  void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void f(String message, {Object? error, StackTrace? stackTrace}) =>
      _emit(LogLevel.fatal, message, error: error, stackTrace: stackTrace);

  void _emit(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < AppLogConfig.minLevel.index) return;

    final safeMessage = AppLogConfig.redactSecrets
        ? LogRedactor.redact(message)
        : message;

    final record = LogRecord(
      timestamp: DateTime.now(),
      level: level,
      logger: name,
      message: safeMessage,
      error: error,
      stackTrace: stackTrace,
    );

    for (final sink in AppLogConfig.sinks) {
      // Sinks must never throw; still guard to avoid cascading failures.
      try {
        sink.write(record);
      } catch (_) {}
    }
  }
}
