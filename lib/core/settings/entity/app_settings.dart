import 'package:drift/drift.dart';

/// Key-value settings persisted locally in Drift.
///
/// Keep it generic so we can add more settings without further schema changes.
class AppSettings extends Table {
  TextColumn get key => text()();

  /// Stored as string (e.g. "true"/"false") to keep schema flexible.
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
