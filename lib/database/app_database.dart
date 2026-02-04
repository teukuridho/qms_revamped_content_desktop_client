import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:qms_revamped_content_desktop_client/media/registry/entity/Media.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/registry/entity/server_properties.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/app_directory/app_directory_service.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Media, ServerProperties])
class AppDatabase extends _$AppDatabase {
  late final AppDirectoryService _appDirectoryService;

  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  LazyDatabase openConnection() {
    return LazyDatabase(() async {
      final dbDirectory = _appDirectoryService.appDirectory;
      final file = File(p.join(dbDirectory.path, 'db.sqlite'));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }
}
