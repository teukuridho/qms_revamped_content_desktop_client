import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_log.dart';
import 'log_level.dart';

class LoggingBootstrap {
  static final AppLog _log = AppLog('bootstrap');

  static Future<void> init() async {
    // Keep release logs lean by default.
    AppLogConfig.minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
    final logPath = await AppLogConfig.enableFileLogging();

    FlutterError.onError = (details) {
      _log.e(
        'FlutterError: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _log.f('Uncaught platform error', error: error, stackTrace: stack);
      // Handled.
      return true;
    };

    _log.i(
      'Logging initialized (minLevel=${AppLogConfig.minLevel.name} file=${logPath ?? "<disabled>"})',
    );
  }

  static R? runZoned<R>(R Function() body) {
    return runZonedGuarded<R>(body, (error, stack) {
      _log.f('Uncaught zone error', error: error, stackTrace: stack);
    });
  }
}
