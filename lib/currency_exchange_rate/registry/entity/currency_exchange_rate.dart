import 'package:drift/drift.dart';

class CurrencyExchangeRates extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  IntColumn get flagImageId => integer().nullable()();

  TextColumn get flagImagePath => text().nullable()();

  TextColumn get countryName => text()();

  TextColumn get currencyCode => text()();

  RealColumn get buy => real()();

  RealColumn get sell => real()();

  IntColumn get position => integer()();

  TextColumn get tag => text()();
}
