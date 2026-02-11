import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

class CurrencyExchangeRateSynchronizerLogger {
  static final AppLog _log = AppLog('currency_exchange_rate_sync');

  static void debug(String message) {
    _log.d(message);
  }

  static void info(String message) {
    _log.i(message);
  }

  static void warn(String message) {
    _log.w(message);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log.e(message, error: error, stackTrace: stackTrace);
  }
}
