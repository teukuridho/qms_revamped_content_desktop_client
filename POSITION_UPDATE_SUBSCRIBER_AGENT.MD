# Position Update Subscriber Agent Notes

Implements an SSE subscriber that listens to position updates and re-emits them via `EventManager`.

This is triggered by the auth event `AuthLoggedInEvent` for a specific `serviceName`.

## Inputs

- `serviceName`: service identifier for this client instance.
- `tag`: subscriber tag used for filtering and subscribe request (for this app: `main`).

Note: Swagger models use `tableName` for the service identifier. In this app, `tableName == serviceName`.

## Current App Wiring

- Config constants: `lib/core/config/app_config.dart`
- Provider injection: `lib/main_screen.dart`

## Output (Event Bus)

The subscriber publishes `PositionUpdatedEventDto` via `EventManager`.

Listeners can subscribe with:

```dart
eventManager.listen<PositionUpdatedEventDto>().listen((dto) {
  // handle dto
});
```

## Manual Injection (Provider)

Typical pattern (manual injection + start in `create`):

```dart
Provider(
  create: (context) {
    final s = PositionUpdateSubscriber(
      serviceName: serviceName,
      tag: 'main',
      sseIncrementalMismatchCallback: (mismatch) {
        // Optional: trigger app-specific recovery (invalidate caches, refetch, etc).
        // The subscriber already logs the mismatch and the SSE client refreshes the connection.
      },
      eventManager: context.read<EventManager>(),
      serverPropertiesRegistryService: context.read<ServerPropertiesRegistryService>(),
    )..init();
    return s;
  },
  dispose: (context, s) {
    // Provider dispose is sync, so we intentionally don't await.
    // ignore: discarded_futures
    s.dispose();
  },
),
```

## Subscribe Flow

1. Listen to `AuthLoggedInEvent` from `EventManager`.
2. If `event.serviceName == serviceName`, start subscribe loop.
3. Load server properties for `serviceName` via `ServerPropertiesRegistryService.getOneByServiceName`.
4. Build SSE URL:

`GET {serverAddress}/position-updated-subscribe?tableName={serviceName}&tag={tag}`

5. Pass `Authorization: Bearer {oidcAccessToken}` header.
6. Use `SseClient` (see `SSE_AGENT.MD`) and listen on field key `position-updated`.
7. Parse payload as `PositionUpdatedEventDto`.
8. If `dto.tableName == serviceName` and `dto.tag == tag`, publish the DTO via `EventManager`.

## Incremental SSE Id Mismatch

`PositionUpdateSubscriber` enables SSE incremental numeric `id:` mismatch detection:

- `enableSseIncrementalIdMismatch = true`
- `shouldRefreshWhenIdMismatch = true`

The subscriber requires `sseIncrementalMismatchCallback` and will invoke it when a mismatch is detected.

## Retry

- If subscribe setup or stream processing throws, the subscriber retries after a delay.
- Delay is configurable via `PositionUpdateSubscriber.retryDelay` (default 3 seconds).

## Implementation

- `lib/core/position_update/subscriber/position_update_subscriber.dart`
- `lib/core/position_update/subscriber/position_update_subscriber_logger.dart`
