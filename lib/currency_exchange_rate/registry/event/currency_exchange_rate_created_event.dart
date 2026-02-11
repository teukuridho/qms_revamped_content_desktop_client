import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';

class CurrencyExchangeRateCreatedEvent {
  late final CurrencyExchangeRate currencyExchangeRate;

  CurrencyExchangeRateCreatedEvent({required this.currencyExchangeRate});
}
