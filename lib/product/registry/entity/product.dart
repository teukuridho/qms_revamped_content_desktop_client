import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  TextColumn get name => text()();

  TextColumn get value => text()();

  IntColumn get position => integer()();

  TextColumn get tag => text()();
}
