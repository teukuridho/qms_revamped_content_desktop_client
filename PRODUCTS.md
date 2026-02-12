# Product Agent Notes

Implements a product table feature that:

- loads all products from backend by `tag`
- stores them in local Drift DB
- renders a 2-column table:
  `PRODUCT NAME | PRODUCT DESC`
- keeps local DB in sync with backend CRUD SSE events
- keeps local ordering in sync with position updates
- uses app-level Provider wiring + `InitService` startup ordering
- supports vertical auto-scroll using `LoopingVerticalAutoScrollCoordinator`

This module should mirror patterns in `MEDIA_AGENT.md`,
`CURRENCY_EXCHANGE_RATE_AGENTS.md`, and `POSITION_UPDATE_SUBSCRIBER_AGENT.MD`.

## Inputs

- `serviceName`: identifies which server-properties row/token is used
- `tag`: filtering key for list + subscriptions + local queries

Proposed app constants (to add in `lib/core/config/app_config.dart`):

- `productServiceName = 'product'`
- `productTag = 'main'`

## Backend Endpoints Used

- List products:
  `GET {serverAddress}/product-registry?page=0&size=9999&sort=position,asc&tag={tag}`
- CRUD subscribe:
  `GET {serverAddress}/product-subscribe?tag={tag}`
- Position subscribe (existing infra):
  `GET {serverAddress}/position-updated-subscribe?tableName={serviceName}&tag={tag}`

OpenAPI references:

- `api/lib/api/product_registry_api.dart`
- `api/lib/model/product_dto.dart`
- `api/lib/model/product_created_event_dto.dart`
- `api/lib/model/product_updated_event_dto.dart`
- `api/lib/model/product_deleted_event_dto.dart`
- `api/lib/model/position_updated_event_dto.dart`

SSE CRUD field keys:

- `created` -> parse `ProductCreatedEventDto`
- `updated` -> parse `ProductUpdatedEventDto`
- `deleted` -> parse `ProductDeletedEventDto`

## Auth

Use the same auth strategy as currency exchange rate/media:

- `OidcAuthService` for bearer token retrieval and refresh retry on 401
- startup bootstrap with `hasUsableAccessTokenNow()` for immediate init
- subscribe loops start/restart on `AuthLoggedInEvent(serviceName)`

## Database (Drift)

Create product table under `lib/product/registry/entity/product.dart`.

Required business fields (from requirement):

- `name`
- `value`
- `tag`
- `position`

Recommended sync field (for parity with media/currency and reliable SSE mapping):

- `remoteId` (backend `ProductDto.id`)

Notes:

- query by `tag`, ordered by `position ASC, id ASC`
- add migration in `lib/core/database/app_database.dart`
- update `schemaVersion`

## Component Plan (Code Map)

Proposed module root: `lib/product/`

- `agent/product_agent.dart`
- `agent/product_feature.dart`
- `downloader/product_downloader.dart`
- `downloader/remote_product_registry_client.dart`
- `registry/entity/product.dart`
- `registry/service/product_registry_service.dart`
- `registry/request/create_product_request.dart`
- `registry/event/product_created_event.dart`
- `registry/event/product_deleted_event.dart`
- `registry/event/product_mass_position_updated_event.dart`
- `synchronizer/product_synchronizer.dart`
- `position_update/product_position_update_listener.dart`
- `view/product_table_view.dart`
- `test/ui/screen/product_test_screen.dart`

## Runtime Flow

1. Agent init:
   init listeners + synchronizer + position listener.
2. If token already usable:
   `reinit()` immediately (`downloadAll`, then start synchronizer).
3. Else:
   wait for `AuthLoggedInEvent` then `reinit()`.
4. `downloadAll()`:
   fetch product list by tag and reconcile local DB.
5. CRUD SSE handling (`/product-subscribe`):
   - `created`: upsert incoming `product`
   - `updated`: upsert incoming `product`
   - `deleted`: delete by incoming `id`
6. Position updates:
   listen `PositionUpdatedEventDto` filtered by
   `tableName == serviceName` and matching `tag`, map remote ids to local ids,
   then call registry `updatePosition(UpdatePositionRequest)`.
7. View updates automatically from Drift watch stream.

## UI Contract

Table columns:

- header text is constructor-driven:
  - `nameHeader` -> left column title
  - `valueHeader` -> right column title
- row mapping:
  - left column -> `name`
  - right column -> `value`

Behavior:

- starts empty/loading
- updates after initial download, CRUD SSE, and position updates
- no app restart required for remote changes
- sticky header + auto-scrolling body when content overflows
- use `lib/core/utility/looping_vertical_auto_scroll.dart`

Target visual example:

```text
-----------------------------------------
DEPOSITO RP           |    Suk Bunga(%p.a)
-----------------------------------------
03 Bulan              |              3.75
03 Bulan              |              3.75
03 Bulan              |              3.75
```

## Logging

Follow `LOG_AGENT.md`:

- use `AppLog('product_*')` across agent/downloader/synchronizer/registry/listener
- log sync start/success/failure and SSE parsing issues
- never log raw tokens

## App Wiring (Provider + InitService)

Follow media/currency pattern:

- `lib/main.dart`
  - add `Provider<ProductFeature>`
  - add a `PositionUpdateSubscriber` for product service/tag
- `lib/core/init/service/init_service.dart`
  - inject `ProductFeature`
  - run `await productFeature.agent.init()`
- `lib/main_screen.dart`
  - include `ProductTableView` in the main content layout
  - do not replace all existing content with an isolated test-only view

## Test Screen

Create and use:

- `lib/product/test/ui/screen/product_test_screen.dart`

Pattern should match:

- `lib/media/test/ui/screen/media_test_screen.dart`
- `lib/currency_exchange_rate/test/ui/screen/currency_exchange_rate_test_screen.dart`

## Notes

- Constructor for main feature/view should include `serviceName` and `tag`.
- Product view constructor should expose header labels (`nameHeader`,
  `valueHeader`).
- Dependency injection should use Provider, same style as media/currency.
- If behavior is unclear, follow existing implementations in `/lib` and `/api`.
