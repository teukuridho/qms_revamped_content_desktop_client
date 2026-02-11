import 'package:drift/drift.dart';

class CurrencyExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  IntColumn get flagImageId => integer().nullable()();

  TextColumn get flagImagePath => text().nullable()();

  TextColumn get countryName => text()();

  TextColumn get currencyCode => text()();

  IntColumn get buy => integer()();

  IntColumn get sell => integer()();

  IntColumn get position => integer()();

  TextColumn get tag => text()();
}
