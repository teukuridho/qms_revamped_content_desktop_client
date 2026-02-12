import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';

class AppSettingsService {
  static const String _fullscreenKey = 'ui.fullscreen';

  final AppDatabaseManager _appDatabaseManager;

  AppSettingsService({required AppDatabaseManager appDatabaseManager})
    : _appDatabaseManager = appDatabaseManager;

  AppDatabase get _db => _appDatabaseManager.appDatabase;

  Future<bool> getFullscreenEnabled() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(_fullscreenKey))).getSingleOrNull();
    if (row == null) return false;
    return row.value.toLowerCase() == 'true';
  }

  Future<void> setFullscreenEnabled(bool enabled) async {
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: _fullscreenKey,
            value: enabled ? 'true' : 'false',
          ),
        );
  }
}
