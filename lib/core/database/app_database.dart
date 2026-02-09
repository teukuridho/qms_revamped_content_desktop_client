import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/entity/server_properties.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/entity/media.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:drift/drift.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Media, ServerProperties])
class AppDatabase extends _$AppDatabase {
  late final AppDirectoryService _appDirectoryService;

  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // No schema changes between v1 and v2.
      },
      from2To3: (m, schema) async {
        await m.createTable(schema.serverProperties);
      },
      from3To4: (m, schema) async {
        // These columns are NOT NULL in v4, so we must provide values for
        // existing rows when migrating from older schemas.
        await m.alterTable(
          TableMigration(
            schema.media,
            newColumns: [
              schema.media.contentType,
              schema.media.mimeType,
              schema.media.tag,
            ],
            columnTransformer: {
              schema.media.contentType: const Constant(''),
              schema.media.mimeType: const Constant(''),
              schema.media.tag: const Constant(''),
            },
          ),
        );
      },
      from4To5:  (m, schema) async {
        // No schema changes
      },
      from5To6: (m, schema) async {
        // New OIDC / Keycloak config + token persistence columns on
        // `server_properties`. These are NOT NULL in v6, so we must provide
        // values for existing rows.
        await m.alterTable(
          TableMigration(
            schema.serverProperties,
            newColumns: [
              schema.serverProperties.keycloakBaseUrl,
              schema.serverProperties.keycloakRealm,
              schema.serverProperties.keycloakClientId,
              schema.serverProperties.oidcAccessToken,
              schema.serverProperties.oidcRefreshToken,
              schema.serverProperties.oidcIdToken,
              schema.serverProperties.oidcExpiresAtEpochMs,
              schema.serverProperties.oidcScope,
              schema.serverProperties.oidcTokenType,
            ],
            columnTransformer: {
              schema.serverProperties.keycloakBaseUrl: const Constant(''),
              schema.serverProperties.keycloakRealm: const Constant(''),
              schema.serverProperties.keycloakClientId: const Constant(''),
              schema.serverProperties.oidcAccessToken: const Constant(''),
              schema.serverProperties.oidcRefreshToken: const Constant(''),
              schema.serverProperties.oidcIdToken: const Constant(''),
              schema.serverProperties.oidcExpiresAtEpochMs: const Constant(0),
              schema.serverProperties.oidcScope: const Constant(''),
              schema.serverProperties.oidcTokenType: const Constant(''),
            },
          ),
        );
      },
      from6To7: (m, schema) async {
        // Drop legacy basic-auth fields (username/password/cookie) from
        // `server_properties`.
        await m.alterTable(TableMigration(schema.serverProperties));
      },
    ),
  );

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
