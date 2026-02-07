import 'package:drift/drift.dart';

class ServerProperties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceName => text()();
  TextColumn get serverAddress => text()();
  TextColumn get username => text()();
  TextColumn get password => text()();
  TextColumn get cookie => text()();
}