# Server Properties Refactor (serviceName + tag)

This document describes the refactor that changes `server_properties` from being keyed by `serviceName` only to being keyed by `(serviceName, tag)`.

The goal is to support running the same `serviceName` with multiple tags at the same time (example: two product tables with different tags on one screen), where each tag can point to different server addresses and different Keycloak/OIDC configuration.

## Why

Previously, `server_properties` effectively assumed a single configuration per `serviceName`.
That prevented:

- Multiple feature instances of the same service on one screen (because they would fight over one config row).
- Per-tag server addresses (example: `product/main` vs `product/branch-a`).
- Per-tag Keycloak config and tokens (example: each tag authenticates against a different realm/client/server).

## Schema Changes

File: `lib/core/server_properties/registry/entity/server_properties.dart`

- Added `tag` column.
- `tag` has default `'main'` to allow safer upgrades on existing installs.
- Enforced uniqueness on `(serviceName, tag)`:
  - Drift: `uniqueKeys => [{serviceName, tag}]`
  - SQLite: `CREATE UNIQUE INDEX IF NOT EXISTS idx_server_properties_service_tag ON server_properties(service_name, tag)`

Current shape (conceptually):

- `serviceName` (TEXT, required)
- `tag` (TEXT, required, default `'main'`)
- `serverAddress` (TEXT, required)
- Keycloak/OIDC config (TEXT defaults)
- Persisted token set columns (TEXT defaults + expiry INT default)

## Registry API Changes

File: `lib/core/server_properties/registry/service/server_properties_registry_service.dart`

- Read:
  - New: `getOneByServiceNameAndTag({required serviceName, required tag})`
- Create:
  - `CreateServerPropertiesRequest` now requires `tag`.
- Update:
  - New: `updateByServiceNameAndTag(UpdateServiceByNameRequest)`
  - `UpdateServiceByNameRequest` now requires `tag`.

Files:

- `lib/core/server_properties/registry/request/create_server_properties_request.dart`
- `lib/core/server_properties/registry/request/update_service_by_name_request.dart`

## UI Changes

File: `lib/core/server_properties/form/ui/view/server_properties_configuration_dialog.dart`

- `ServerPropertiesConfigurationDialog` now requires both:
  - `serviceName`
  - `tag`
- The dialog creates:
  - `ServerPropertiesFormViewModel(serviceName, tag)`
  - `OidcAuthService(serviceName, tag, ...)`

This is what enables configuring multiple `(serviceName, tag)` pairs from the same app session.

## Auth Changes

File: `lib/core/auth/auth_service.dart`

- `OidcAuthService` now requires `tag` in its constructor and always loads/persists tokens using:
  - `ServerPropertiesRegistryService.getOneByServiceNameAndTag(serviceName, tag)`
  - `ServerPropertiesRegistryService.updateByServiceNameAndTag(serviceName, tag, ...)`

Impact:

- Tokens are stored per `(serviceName, tag)`, so different tags can authenticate independently.
- Logout clears tokens only for the specific `(serviceName, tag)` pair.

## Event Changes

File: `lib/core/auth/event/auth_logged_in_event.dart`

- `AuthLoggedInEvent` now includes `tag`.
- Any subscriber that reacts to login events should filter by both:
  - `serviceName`
  - `tag`

## Database Migration Notes

File: `lib/core/database/app_database.dart`

- Current `schemaVersion` is `13`.
- For the `server_properties.tag` change, the migration intentionally avoids using:
  - `TableMigration(serverProperties)`

Reason:

- On older/dirty databases, Drift-generated table copy SQL can reference columns (like `tag`) before they exist, which can cause failures like `SqliteException(1): no such column: "tag"`.

Instead, the migration uses defensive, idempotent raw SQL:

- Add column:
  - `ALTER TABLE server_properties ADD COLUMN tag TEXT NOT NULL DEFAULT 'main'`
- Normalize older rows:
  - `UPDATE server_properties SET tag='main' WHERE tag=''`
- Dedupe to allow uniqueness:
  - Keep only the max `id` for each `(service_name, tag)`
- Enforce uniqueness:
  - `CREATE UNIQUE INDEX IF NOT EXISTS idx_server_properties_service_tag ON server_properties(service_name, tag)`

Additionally, for best-effort repair when a DB is out-of-sync, there is a self-heal step:

- `AppDatabase.selfHealSchemaIfNeeded()`
- Called early from `AppDatabaseManager.init()` (before feature queries)

File: `lib/core/database/app_database_manager.dart`

## How To Use In Features

Pattern:

- Each feature instance should be constructed with:
  - `serviceName` (logical service identity)
  - `tag` (logical instance identity, fixed in code)
- Any place that loads configuration must use `(serviceName, tag)`:
  - server address
  - Keycloak base URL / realm / client id
  - persisted OIDC tokens

Example (conceptual):

- `ProductFeature(serviceName: 'product', tag: 'main')`
- `ProductFeature(serviceName: 'product', tag: 'branch-a')`

Both can run concurrently and can point to different server + Keycloak config.

## Troubleshooting

If you see errors like:

- `SqliteException(1): no such column: "tag"`

It usually means you are running against an older or partially-migrated `db.sqlite`.
The intended behavior is:

- Drift upgrade runs, then defensive `_ensureServerPropertiesTagExistsAndUnique()` runs.
- `AppDatabaseManager.init()` force-opens and calls `selfHealSchemaIfNeeded()` before other feature code reads `server_properties`.

The database logs include a line like:

- `[db_migrate] selfHealSchemaIfNeeded(user_version=...)`

If it is missing, it suggests the failure happened before the self-heal ran (or before Drift could open the DB).

