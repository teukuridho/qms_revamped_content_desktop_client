import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/settings/entity/app_settings.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/entity/server_properties.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/entity/currency_exchange_rate.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/entity/media.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/entity/product.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:drift/drift.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Media,
    ServerProperties,
    CurrencyExchangeRates,
    Products,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  static final AppLog _log = AppLog('db_migrate');

  late final AppDirectoryService _appDirectoryService;

  AppDatabase(super.executor);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      final migrateToV7 = stepByStep(
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
        from4To5: (m, schema) async {
          // No schema changes.
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
      );

      if (from < 7) {
        await migrateToV7(m, from, to < 7 ? to : 7);
      }

      if (to >= 8 && from < 8) {
        await m.createTable(currencyExchangeRates);
      }

      if (to >= 9 && from >= 8 && from < 9) {
        await _migrateCurrencyExchangeRateBuySellToReal();
      }

      if (to >= 10 && from < 10) {
        await m.createTable(products);
      }

      if (to >= 11 && from < 11) {
        // `server_properties` is now keyed by (serviceName, tag).
        // Do not use `TableMigration(serverProperties)` here: older databases
        // may not have the `tag` column yet and the generated copy statement
        // can reference it before it exists, causing `no such column: tag`.
        await _ensureServerPropertiesTagExistsAndUnique();
      }

      if (to >= 12 && from < 12) {
        // Defensive migration for older/dirty databases:
        // - Ensure tag/content_type/mime_type columns exist where expected.
        // - Ensure server_properties has tag and a uniqueness constraint by
        //   (service_name, tag). Older builds could have duplicate rows.
        await _ensureMediaTagColumnsExist();
        await _ensureServerPropertiesTagExistsAndUnique();
      }

      if (to >= 13 && from < 13) {
        // Re-run defensive checks in case a previous upgrade attempt partially
        // applied schema changes but left the DB in an inconsistent state.
        await _ensureMediaTagColumnsExist();
        await _ensureServerPropertiesTagExistsAndUnique();
      }

      if (to >= 14 && from < 14) {
        await m.createTable(appSettings);
      }
    },
  );

  Future<void> _tryStatement(
    String sql, {
    bool ignoreDuplicateColumn = false,
    bool ignoreDuplicateIndex = false,
  }) async {
    try {
      await customStatement(sql);
    } catch (e, st) {
      final msg = e.toString().toLowerCase();
      if (ignoreDuplicateColumn && msg.contains('duplicate column name')) {
        return;
      }
      if (ignoreDuplicateIndex &&
          (msg.contains('already exists') || msg.contains('duplicate'))) {
        return;
      }
      _log.e('Migration statement failed: $sql', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> _ensureMediaTagColumnsExist() async {
    await _tryStatement(
      "ALTER TABLE media ADD COLUMN content_type TEXT NOT NULL DEFAULT ''",
      ignoreDuplicateColumn: true,
    );
    await _tryStatement(
      "ALTER TABLE media ADD COLUMN mime_type TEXT NOT NULL DEFAULT ''",
      ignoreDuplicateColumn: true,
    );
    await _tryStatement(
      "ALTER TABLE media ADD COLUMN tag TEXT NOT NULL DEFAULT 'main'",
      ignoreDuplicateColumn: true,
    );

    // Normalize older rows inserted before tag existed.
    await _tryStatement("UPDATE media SET tag='main' WHERE tag=''");
  }

  Future<void> _ensureServerPropertiesTagExistsAndUnique() async {
    await _tryStatement(
      "ALTER TABLE server_properties ADD COLUMN tag TEXT NOT NULL DEFAULT 'main'",
      ignoreDuplicateColumn: true,
    );

    await _tryStatement("UPDATE server_properties SET tag='main' WHERE tag=''");

    // Keep only one row per (service_name, tag) so uniqueness can be enforced.
    await _tryStatement('''
DELETE FROM server_properties
WHERE id NOT IN (
  SELECT MAX(id)
  FROM server_properties
  GROUP BY service_name, tag
)
''');

    await _tryStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS idx_server_properties_service_tag
ON server_properties(service_name, tag)
''', ignoreDuplicateIndex: true);
  }

  /// Best-effort schema repair for databases that are out-of-sync with Drift
  /// migrations (for example, due to partial upgrades or older binaries).
  ///
  /// This should be safe to run multiple times.
  Future<void> selfHealSchemaIfNeeded() async {
    try {
      // Touch the database so we get a clearer log ordering.
      final uv = await customSelect('PRAGMA user_version').getSingle();
      _log.i('selfHealSchemaIfNeeded(user_version=${uv.data['user_version']})');
    } catch (_) {
      // Ignore; some platforms/drivers may not support getSingle here.
    }

    await _ensureMediaTagColumnsExist();
    await _ensureServerPropertiesTagExistsAndUnique();
  }

  Future<void> _migrateCurrencyExchangeRateBuySellToReal() async {
    await customStatement('''
CREATE TABLE currency_exchange_rates_new (
  id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
  remote_id INTEGER NOT NULL,
  flag_image_id INTEGER NULL,
  flag_image_path TEXT NULL,
  country_name TEXT NOT NULL,
  currency_code TEXT NOT NULL,
  buy REAL NOT NULL,
  sell REAL NOT NULL,
  position INTEGER NOT NULL,
  tag TEXT NOT NULL
)
''');

    await customStatement('''
INSERT INTO currency_exchange_rates_new (
  id,
  remote_id,
  flag_image_id,
  flag_image_path,
  country_name,
  currency_code,
  buy,
  sell,
  position,
  tag
)
SELECT
  id,
  remote_id,
  flag_image_id,
  flag_image_path,
  country_name,
  currency_code,
  CAST(buy AS REAL),
  CAST(sell AS REAL),
  position,
  tag
FROM currency_exchange_rates
''');

    await customStatement('DROP TABLE currency_exchange_rates');
    await customStatement(
      'ALTER TABLE currency_exchange_rates_new RENAME TO currency_exchange_rates',
    );

    await customStatement(
      "DELETE FROM sqlite_sequence WHERE name = 'currency_exchange_rates'",
    );
    await customStatement('''
INSERT INTO sqlite_sequence(name, seq)
SELECT 'currency_exchange_rates', COALESCE(MAX(id), 0)
FROM currency_exchange_rates
''');
  }

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
