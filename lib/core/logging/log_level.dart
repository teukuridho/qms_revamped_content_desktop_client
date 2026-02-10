enum LogLevel { trace, debug, info, warn, error, fatal }

extension LogLevelDev on LogLevel {
  /// Maps to conventional Dart log levels used by `dart:developer`.
  int get developerLevel {
    switch (this) {
      case LogLevel.trace:
        return 300;
      case LogLevel.debug:
        return 700;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
      case LogLevel.fatal:
        return 1000;
    }
  }

  String get label {
    switch (this) {
      case LogLevel.trace:
        return 'T';
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warn:
        return 'W';
      case LogLevel.error:
        return 'E';
      case LogLevel.fatal:
        return 'F';
    }
  }
}
