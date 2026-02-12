# Media Agent Notes

Implements a media feature that:

- downloads media registry entries from backend
- stores files locally under the app directory
- plays a playlist (video via `media_kit`, image via `Image.file`)
- synchronizes changes via SSE (`media-uploaded`, `media-deleted`)
- reorders on position updates (via `PositionUpdatedEventDto` -> local registry update)
- reloads playlist order at end-of-loop after mass position changes
- self-heals SSE drift: on incremental-id mismatch, does full backend refresh
- renders video with full-frame letterbox behavior (`BoxFit.contain`) and
  black bars when aspect ratio does not match the viewport
- uses video controller UI (playback controls visible in video view)

This module follows the same patterns as `POSITION_UPDATE_SUBSCRIBER_AGENT.MD`:

- app-level Provider creation in `main.dart`
- startup initialization in `InitService`
- event-driven orchestration via `EventManager`
- SSE reconnect loop with retry delay

## Inputs

- `serviceName`: logical service identity (used in `server_properties`)
- `tag`: media playlist tag (filtering for downloads + SSE)

Server properties selection:

- Config + Keycloak/OIDC tokens are loaded from `server_properties` by
  `(serviceName, tag)`, not by `serviceName` alone. This allows multiple
  instances of the same serviceName with different tags to run concurrently.

Current app constants:

- `serviceName = AppConfig.mediaServiceName` (`media`)
- `tag = AppConfig.mediaTag` (`main`)

## Backend Endpoints Used

- List medias: `GET {serverAddress}/media-registry?page=0&size=9999&sort=position,asc&tag={tag}`
- Download file: `GET {serverAddress}/media-storage/{id}/download`
- Subscribe: `GET {serverAddress}/media-subscribe?tag={tag}` (SSE)

SSE fields:

- `media-uploaded`: payload parses as `MediaUploadedEventDto`
- `media-deleted`: payload parses as `MediaDeletedEventDto`
- media SSE enables incremental `id:` mismatch detection; mismatch triggers a
  full media refresh from backend (`downloadAll`) and schedules reload

## Local Storage

- Directory creation: `lib/media/storage/directory/media_storage_directory_service.dart`
- Files are written under `AppDirectory/<media dir name>/` (default `media/`)
- File naming: `MediaStorageFileService` sanitizes remote file names and
  truncates long names (while preserving extension) to reduce Windows path/filename
  length issues.
- Download behavior: files are streamed into a unique temp file
  `*.part.<timestamp>` and then finalized into place with retries + a copy
  fallback (helps with transient Windows rename failures due to AV/indexing or
  concurrent readers).
- DB table: `lib/media/registry/entity/media.dart`

## Components (Code Map)

- Orchestrator: `lib/media/agent/media_agent.dart`
- Wiring helper: `lib/media/agent/media_feature.dart`
- Test screen: `lib/media/test/ui/screen/media_test_screen.dart`
  (fixed `serviceName = AppConfig.mediaServiceName`, `tag = AppConfig.mediaTag`)
- Downloader:
  - `lib/media/downloader/media_downloader.dart`
  - `lib/media/downloader/remote_media_registry_client.dart` (OpenAPI list)
  - `lib/media/downloader/remote_media_storage_client.dart` (HTTP download)
- Player:
  - `lib/media/player/controller/media_player_controller.dart`
  - `lib/media/player/ui/media_player_view.dart`
  - Events: `lib/media/player/event/*`

## Video Rendering Behavior

- Video is rendered full-frame with `BoxFit.contain` to avoid clipping.
- When viewport ratio differs from video ratio, top/bottom or side black bars
  are expected (letterbox/pillarbox).
- Video controller UI is enabled in the player view.
- Synchronizer (SSE): `lib/media/synchronizer/media_synchronizer.dart`
- Position update listener: `lib/media/position_update/media_position_update_listener.dart`
- Mass position listener:
  `lib/media/position_update/media_mass_position_updated_event_listener.dart`
- Deleter: `lib/media/storage/service/media_deleter.dart`

## Position Update Flow

1. `PositionUpdateSubscriber` publishes `PositionUpdatedEventDto`.
   On SSE incremental `id:` mismatch it also publishes
   `PositionUpdateSseIdMismatchEvent`.
2. `MediaPositionUpdateListener` filters by `tableName == serviceName` and
   `tag == tag`, maps SSE `id`/`affectedRecordRows[].id` (remote ids) to local
   Drift row ids by `(remoteId, tag)`, then calls
   `MediaRegistryService.updatePosition(UpdatePositionRequest)`.
3. `MediaRegistryService` updates local media positions and publishes
   `MediaMassPositionUpdatedEvent`.
4. `MediaMassPositionUpdatedEventListener` marks media reload needed.
5. `MediaPlayerController` reloads from DB when playlist reaches the last item,
   so new positions are applied without interrupting current playback.

Mismatch recovery:

- `MediaAgent` listens `PositionUpdateSseIdMismatchEvent` and, when
  `serviceName/tag` match, runs `reinit(autoPlay: false, startSynchronizer: false)`
  to reload medias from backend and refresh playlist without restarting playback.

## Initial Refresh Behavior

- On `MediaAgent.init()`, if a usable token already exists, `reinit(...)` runs
  immediately (`downloadAll` + DB load + optional autoplay).
- If no usable token exists yet, refresh runs after `AuthLoggedInEvent`.

## Context Menu (Right Click)

`MediaPlayerView` exposes a desktop context menu on right-click:

- `Configure Server & Auth`: opens configuration/auth dialog (reuses
  `ServerPropertiesFormView` + `AuthSection` stack via
  `ServerPropertiesConfigurationDialog`)
- `Reinitialize Media`: optional action via callback to trigger media reinit
  after config/auth changes; test screen implementation restarts playback from
  first media item after reinit

`MediaPlayerView` constructor requires:

- `serverPropertiesRegistryService` for config/auth dialog
- optional `onReinitializeRequested` callback if host wants reinit action enabled

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

## Event Bus Contracts

Player commands:

- `MediaPlayEvent(serviceName, tag, reason)`
- `MediaStopEvent(serviceName, tag, reason)`

Downloader UI events (for snackbars in media UI):

- `MediaDownloadStartedEvent(serviceName, tag)` (sticky snackbar)
- `MediaDownloadSucceededEvent(serviceName, tag, downloadedCount)` (success snackbar)
- `MediaDownloadFailedEvent(serviceName, tag, message)` (error snackbar)

## Usage (App-Level Providers + InitService)

Current app wiring:

```dart
// main.dart
Provider<MediaFeature>(
  create: (context) => MediaFeature.create(
    serviceName: AppConfig.mediaServiceName,
    tag: AppConfig.mediaTag,
    eventManager: context.read<EventManager>(),
    appDatabaseManager: context.read<AppDatabaseManager>(),
    serverPropertiesRegistryService:
        context.read<ServerPropertiesRegistryService>(),
    mediaStorageDirectoryService:
        context.read<MediaStorageDirectoryService>(),
  ),
);

// init_service.dart
await mediaFeature.agent.init();

// main_screen.dart
final mediaFeature = context.read<MediaFeature>();
MediaPlayerView(
  serviceName: AppConfig.mediaServiceName,
  tag: AppConfig.mediaTag,
  controller: mediaFeature.playerController,
  ...
);
```

## Notes / Tweaks

- Image duration is configurable via `MediaPlayerController.defaultImageDuration`.
- `MediaSynchronizer` retries on exceptions; delay is configurable via
  `MediaSynchronizer.retryDelay`.
- `MediaAgent` calls `OidcAuthService.hasUsableAccessTokenNow()` on startup so the
  feature can initialize even if the user is already logged in (no fresh
  `AuthLoggedInEvent`).

