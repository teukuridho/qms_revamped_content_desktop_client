import 'package:drift/drift.dart';

class Media extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get remoteId => integer()();

  TextColumn get path => text()();

  IntColumn get position => integer()();

  TextColumn get contentType => text()();

  TextColumn get mimeType => text()();

  TextColumn get tag => text()();
}
