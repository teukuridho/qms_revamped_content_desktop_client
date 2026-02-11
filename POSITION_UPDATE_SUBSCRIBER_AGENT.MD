# Position Update Subscriber Agent Notes

Implements an SSE subscriber that listens to position updates and re-emits them via `EventManager`.

This is triggered by the auth event `AuthLoggedInEvent` for a specific `serviceName`.

## Inputs

- `serviceName`: service identifier for this client instance.
- `tag`: subscriber tag used for filtering and subscribe request (for this app: `main`).

Note: Swagger models use `tableName` for the service identifier. In this app, `tableName == serviceName`.

## Current App Wiring

- Config constants: `lib/core/config/app_config.dart`
- Provider creation: `lib/main.dart`
- Subscriber startup (`init()`): `lib/core/init/service/init_service.dart`

## Output (Event Bus)

The subscriber publishes:

- `PositionUpdatedEventDto` when valid position data is received and matches `serviceName` + `tag`.
- `PositionUpdateSseIdMismatchEvent` when SSE incremental `id:` mismatch is detected.

Listeners can subscribe with:

```dart
eventManager.listen<PositionUpdatedEventDto>().listen((dto) {
  // handle dto
});

eventManager.listen<PositionUpdateSseIdMismatchEvent>().listen((event) {
  // event.serviceName
  // event.tag
  // event.occurredAtEpochMs
  // event.mismatch (expectedId, actualIdRaw, reason, etc)
});
```

## App Startup Injection (Provider + InitService)

Current app pattern (create in `main.dart`, initialize in `InitService`):

```dart
Provider<List<PositionUpdateSubscriber>>(
  create: (context) => [
    PositionUpdateSubscriber(
      serviceName: AppConfig.mediaServiceName,
      tag: AppConfig.mediaTag,
      sseIncrementalMismatchCallback: (_) {},
      eventManager: context.read<EventManager>(),
      serverPropertiesRegistryService:
          context.read<ServerPropertiesRegistryService>(),
    ),
    PositionUpdateSubscriber(
      serviceName: AppConfig.currencyExchangeRateServiceName,
      tag: AppConfig.currencyExchangeRateTag,
      sseIncrementalMismatchCallback: (_) {},
      eventManager: context.read<EventManager>(),
      serverPropertiesRegistryService:
          context.read<ServerPropertiesRegistryService>(),
    ),
  ],
);

// InitService.init()
for (final subscriber in positionUpdateSubscribers) {
  subscriber.init();
}
```

Reason: subscribers must attach auth listeners before the user logs in.

## Alternate Screen-Scoped Injection

You can still do screen-scoped injection when needed:

```dart
Provider(
  create: (context) => PositionUpdateSubscriber(
    serviceName: serviceName,
    tag: tag,
    sseIncrementalMismatchCallback: (_) {},
    eventManager: context.read<EventManager>(),
    serverPropertiesRegistryService:
        context.read<ServerPropertiesRegistryService>(),
  )..init(),
  dispose: (context, s) {
    // ignore: discarded_futures
    s.dispose();
  },
),
```

## Subscribe Flow

1. Listen to `AuthLoggedInEvent` from `EventManager`.
2. Also at `init()`, if a usable token already exists, start subscribe loop
   immediately (no need to wait for a new login event).
3. If `event.serviceName == serviceName`, start subscribe loop.
4. Load server properties for `serviceName` via `ServerPropertiesRegistryService.getOneByServiceName`.
5. Build SSE URL:

`GET {serverAddress}/position-updated-subscribe?tableName={serviceName}&tag={tag}`

6. Resolve token via `OidcAuthService.getValidAccessToken()` and pass
   `Authorization: Bearer {token}` header.
7. Use `SseClient` (see `SSE_AGENT.MD`) and listen on field key `position-updated`.
8. Parse payload as `PositionUpdatedEventDto`.
9. If `dto.tableName == serviceName` and `dto.tag == tag`, publish the DTO via `EventManager`.
10. If `tableName/tag` does not match, log a warning and ignore the event.

## Incremental SSE Id Mismatch

`PositionUpdateSubscriber` enables SSE incremental numeric `id:` mismatch detection:

- `enableSseIncrementalIdMismatch = true`
- `shouldRefreshWhenIdMismatch = true`

The subscriber requires `sseIncrementalMismatchCallback` and will invoke it when a mismatch is detected.
It also publishes `PositionUpdateSseIdMismatchEvent` through `EventManager`.

## Retry

- If subscribe setup or stream processing throws, the subscriber retries after a delay.
- Delay is configurable via `PositionUpdateSubscriber.retryDelay` (default 3 seconds).

## Implementation

- `lib/core/position_update/subscriber/position_update_subscriber.dart`
- `lib/core/position_update/subscriber/position_update_subscriber_logger.dart`
- `lib/core/position_update/subscriber/event/position_update_sse_id_mismatch_event.dart`
