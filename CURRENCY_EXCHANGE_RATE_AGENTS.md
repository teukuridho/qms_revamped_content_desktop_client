# Currency Exchange Rate Agent Notes

Implements a currency exchange rate feature that:

- loads all rates from backend by `tag`
- stores them in local Drift DB
- renders table rows:
  `FLAG | COUNTRY NAME | CURRENCY_CODE | BUY | SELL`
- keeps local DB in sync with backend CRUD SSE events
- keeps local ordering in sync with position updates
- uses app-level Provider wiring + `InitService` startup ordering

This module should mirror the patterns in `MEDIA_AGENT.md` and
`POSITION_UPDATE_SUBSCRIBER_AGENT.MD`.

## Inputs

- `serviceName`: identifies which server-properties row/token is used
- `tag`: filtering key for list + subscriptions + local queries

Current app constants:

- `serviceName = AppConfig.currencyExchangeRateServiceName` (`currency_exchange_rate`)
- `tag = AppConfig.currencyExchangeRateTag` (`main`)

## Backend Endpoints Used

- List rates:
  `GET {serverAddress}/currency-exchange-rate-registry?page=0&size=9999&sort=position,asc&tag={tag}`
- Download flag image:
  `GET {serverAddress}/flag-image-storage/{flagImageId}/download`
- Position subscribe (already existing infra):
  `GET {serverAddress}/position-updated-subscribe?tableName={serviceName}&tag={tag}`
- CRUD subscribe (requirement from product spec):
  `GET {serverAddress}/currency-exchange-rate-subscribe`
  (parse currency CRUD events from SSE fields)

OpenAPI references:

- `api/lib/api/currency_exchange_rate_registry_api.dart`
- `api/lib/api/flag_image_storage_api.dart`
- `api/lib/model/currency_exchange_rate_created_event_dto.dart`
- `api/lib/model/currency_exchange_rate_updated_event_dto.dart`
- `api/lib/model/currency_exchange_rate_deleted_event_dto.dart`

## Auth

Use the same auth strategy as media:

- `OidcAuthService` for valid bearer token retrieval and refresh retry on 401
- optional startup bootstrap with `hasUsableAccessTokenNow()` for immediate init
- subscribe loops start/restart on `AuthLoggedInEvent(serviceName)`

See `MEDIA_AGENT.md` and `lib/media/downloader/media_downloader.dart`.

## Local Storage

Flag images are stored on disk (media-style), not in DB blob fields:

- create directory under app directory, e.g. `currency_exchange_rate_flags/`
- file naming should be stable by remote `flagImageId`
- use atomic write (`.part` -> rename), same safety as media storage download

## Database (Drift)

Add a new table for exchange rows (module-local, similar to media registry):

- `remoteId` (backend id)
- `flagImagePath` (local path; nullable when no flag image)
- `countryName` (UI label; mapped from backend `currencyName` unless backend changes)
- `currencyCode`
- `buy`
- `sell`
- `position`
- `tag`

Notes:

- keep rows queryable by `tag`, ordered by `position ASC, id ASC`
- update `schemaVersion` and add migration step in
  `lib/core/database/app_database.dart`

## Component Plan (Code Map)

Proposed module root: `lib/currency_exchange_rate/`

- `agent/currency_exchange_rate_agent.dart`
- `agent/currency_exchange_rate_feature.dart`
- `downloader/currency_exchange_rate_downloader.dart`
- `downloader/remote_currency_exchange_rate_registry_client.dart`
- `downloader/remote_flag_image_storage_client.dart`
- `registry/entity/currency_exchange_rate.dart`
- `registry/service/currency_exchange_rate_registry_service.dart`
- `registry/request/create_currency_exchange_rate_request.dart`
- `registry/event/*` (created/deleted/mass-position-updated as needed)
- `synchronizer/currency_exchange_rate_synchronizer.dart`
- `position_update/currency_exchange_rate_position_update_listener.dart`
- `position_update/currency_exchange_rate_mass_position_updated_event_listener.dart`
- `storage/directory/currency_exchange_rate_flag_storage_directory_service.dart`
- `storage/service/currency_exchange_rate_flag_storage_file_service.dart`
- `view/currency_exchange_rate_table_view.dart`
- `test/ui/screen/currency_exchange_rate_test_screen.dart`

## Runtime Flow

1. Agent init:
   init storage dir, init view/controller listeners, init synchronizers/listeners.
2. If token already usable:
   `reinit()` immediately (download all, upsert DB, load UI model).
3. Else:
   wait for `AuthLoggedInEvent` then `reinit()`.
4. `downloadAll()`:
   fetch rate list by tag, reconcile local DB, download/update flag files, upsert rows.
5. CRUD SSE handling:
   - field `created`: parse `CurrencyExchangeRateCreatedEventDto`,
     upsert row + download flag if needed
   - field `updated`: parse `CurrencyExchangeRateUpdatedEventDto`,
     upsert row + refresh flag if `flagImageId` changed
   - field `deleted`: parse `CurrencyExchangeRateDeletedEventDto`,
     delete row (+ optional orphan flag cleanup)
6. Position updates:
   listen `PositionUpdatedEventDto` filtered by `tableName == serviceName` and `tag`,
   map SSE `id`/`affectedRecordRows[].id` (remote ids) to local Drift row ids
   by `(remoteId, tag)`, then call registry `updatePosition(UpdatePositionRequest)`.
7. Mass position event:
   notify table controller/view to reload ordered list.

## UI Contract

Table columns:

- `FLAG`: local file image (placeholder when missing)
- `COUNTRY NAME`: from local `countryName`
- `CURRENCY_CODE`
- `BUY`
- `SELL`

Formatting:

- `BUY` and `SELL` must be rendered as formatted decimal/currency values

Minimum behavior:

- starts empty/loading
- updates automatically after initial download, CRUD events, and position updates
- does not require app restart for remote changes

Dialog lifecycle note:

- Do not create `ServerPropertiesFormViewModel` / `AuthViewModel` in the
  caller and dispose them in `showDialog(...).finally(...)`.
- Controllers can be disposed before the dialog route fully unmounts
  (reverse animation), causing
  `A TextEditingController was used after being disposed`.
- Keep ownership inside `ServerPropertiesConfigurationDialog` and dispose in
  that widget's `dispose()` instead.
- Reference implementation:
  `lib/core/server_properties/form/ui/view/server_properties_configuration_dialog.dart`

## App Wiring (Same Pattern as Media)

At app startup:

- create `CurrencyExchangeRateFeature` in `lib/main.dart`
- create `PositionUpdateSubscriber` instances in `lib/main.dart`
- run `subscriber.init()` and `feature.agent.init()` in `lib/core/init/service/init_service.dart`
- keep `lib/main_screen.dart` as a pure consumer of provided instances

Test harness target:

- `lib/currency_exchange_rate/test/ui/screen/currency_exchange_rate_test_screen.dart`
- route from `lib/main_screen.dart` while developing

Fixed test constants:

- `serviceName = AppConfig.currencyExchangeRateServiceName`
- `tag = AppConfig.currencyExchangeRateTag`

Field mapping:

- UI `country_name` maps from backend `currencyName`
