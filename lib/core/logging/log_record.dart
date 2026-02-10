import 'log_level.dart';

class LogRecord {
  final DateTime timestamp;
  final LogLevel level;
  final String logger;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogRecord({
    required this.timestamp,
    required this.level,
    required this.logger,
    required this.message,
    this.error,
    this.stackTrace,
  });
}
