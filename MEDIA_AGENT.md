# Media Agent Notes

Implements a media feature that:

- downloads media registry entries from backend
- stores files locally under the app directory
- plays a playlist (video via `media_kit`, image via `Image.file`)
- synchronizes changes via SSE (`media-uploaded`, `media-deleted`)
- reorders on position updates (via `PositionUpdatedEventDto` -> local registry update)
- reloads playlist order at end-of-loop after mass position changes
- renders video with full-frame letterbox behavior (`BoxFit.contain`) and
  black bars when aspect ratio does not match the viewport
- uses video controller UI (playback controls visible in video view)

This module follows the same patterns as `POSITION_UPDATE_SUBSCRIBER_AGENT.MD`:

- manual Provider injection
- event-driven orchestration via `EventManager`
- SSE reconnect loop with retry delay

## Inputs

- `serviceName`: which server-properties row to use (same concept as other services)
- `tag`: media playlist tag (filtering for downloads + SSE)

## Backend Endpoints Used

- List medias: `GET {serverAddress}/media-registry?page=0&size=9999&sort=position,asc&tag={tag}`
- Download file: `GET {serverAddress}/media-storage/{id}/download`
- Subscribe: `GET {serverAddress}/media-subscribe?tag={tag}` (SSE)

SSE fields:

- `media-uploaded`: payload parses as `MediaUploadedEventDto`
- `media-deleted`: payload parses as `MediaDeletedEventDto`

## Local Storage

- Directory creation: `lib/media/storage/directory/media_storage_directory_service.dart`
- Files are written under `AppDirectory/<media dir name>/` (default `media/`)
- DB table: `lib/media/registry/entity/media.dart`

## Components (Code Map)

- Orchestrator: `lib/media/agent/media_agent.dart`
- Wiring helper: `lib/media/agent/media_feature.dart`
- Test screen: `lib/media/test/ui/screen/media_test_screen.dart`
  (fixed `serviceName = 'main-media'`, `tag = 'main'`)
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
2. `MediaPositionUpdateListener` filters by `tableName == serviceName` and
   `tag == tag`, then calls
   `MediaRegistryService.updatePosition(UpdatePositionRequest)`.
3. `MediaRegistryService` updates local media positions and publishes
   `MediaMassPositionUpdatedEvent`.
4. `MediaMassPositionUpdatedEventListener` marks media reload needed.
5. `MediaPlayerController` reloads from DB when playlist reaches the last item,
   so new positions are applied without interrupting current playback.

## Context Menu (Right Click)

`MediaPlayerView` exposes a desktop context menu on right-click:

- `Configure Server & Auth`: opens configuration/auth dialog (reuses
  `ServerPropertiesFormView` + `AuthSection` stack)
- `Reinitialize Media`: optional action via callback to trigger media reinit
  after config/auth changes; test screen implementation restarts playback from
  first media item after reinit

`MediaPlayerView` constructor requires:

- `serverPropertiesRegistryService` for config/auth dialog
- optional `onReinitializeRequested` callback if host wants reinit action enabled

## Event Bus Contracts

Player commands:

- `MediaPlayEvent(serviceName, tag, reason)`
- `MediaStopEvent(serviceName, tag, reason)`

Downloader UI events (for snackbars in media UI):

- `MediaDownloadStartedEvent(serviceName, tag)` (sticky snackbar)
- `MediaDownloadSucceededEvent(serviceName, tag, downloadedCount)` (success snackbar)
- `MediaDownloadFailedEvent(serviceName, tag, message)` (error snackbar)

## Usage (Manual Provider Injection)

Minimal example wiring for a screen that embeds the media player:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/agent/media_feature.dart';
import 'package:qms_revamped_content_desktop_client/media/player/ui/media_player_view.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/directory/media_storage_directory_service.dart';

class MyMediaScreen extends StatelessWidget {
  const MyMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const serviceName = 'main-media';
    const tag = 'main';

    return Provider<MediaFeature>(
      create: (context) {
        final feature = MediaFeature.create(
          serviceName: serviceName,
          tag: tag,
          eventManager: context.read<EventManager>(),
          appDatabaseManager: context.read<AppDatabaseManager>(),
          serverPropertiesRegistryService:
              context.read<ServerPropertiesRegistryService>(),
          mediaStorageDirectoryService:
              context.read<MediaStorageDirectoryService>(),
        );
        // Provider create can be async via "unawaited".
        // ignore: discarded_futures
        feature.agent.init();
        return feature;
      },
      dispose: (context, feature) {
        // ignore: discarded_futures
        feature.agent.dispose();
      },
      child: Builder(
        builder: (context) {
          final feature = context.read<MediaFeature>();
          return Scaffold(
            body: MediaPlayerView(
              serviceName: serviceName,
              tag: tag,
              eventManager: context.read<EventManager>(),
              serverPropertiesRegistryService:
                  context.read<ServerPropertiesRegistryService>(),
              controller: feature.playerController,
              onReinitializeRequested: () async {
                await feature.agent.reinit(
                  autoPlay: true,
                  startSynchronizer: true,
                );
                await feature.playerController.playFromFirst(
                  reason: 'context_menu_reinitialize',
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

## Notes / Tweaks

- Image duration is configurable via `MediaPlayerController.defaultImageDuration`.
- `MediaSynchronizer` retries on exceptions; delay is configurable via
  `MediaSynchronizer.retryDelay`.
- `MediaAgent` calls `OidcAuthService.hasUsableAccessTokenNow()` on startup so the
  feature can initialize even if the user is already logged in (no fresh
  `AuthLoggedInEvent`).

