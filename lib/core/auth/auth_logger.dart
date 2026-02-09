import 'dart:developer' as dev;

class AuthLogger {
  static const String _name = 'auth';

  static void info(String message) {
    dev.log(message, name: _name, level: 800);
  }

  static void warn(String message) {
    dev.log(message, name: _name, level: 900);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(message, name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }
}

