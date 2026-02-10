# SSE Agent Notes

This repo’s SSE client lives in `lib/sse_client/`.

## API

Create a client:

```dart
import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

final sse = SseClient(
  SseClientOptions(
    url: Uri.parse('https://example.com/sse'),
    headers: {
      'Authorization': 'Bearer <token>',
    },
    cookies: {
      'session': '<cookie>',
    },
  ),
);
```

Listen to any field key as a `String`:

```dart
final sub = sse.listenString('data').listen((value) {
  // value is the raw field value
});
```

Listen and parse JSON:

```dart
final sub = sse.listenJson('position-updated').listen((value) {
  // value is jsonDecode(...) result (Map/List/etc)
});
```

Close:

```dart
await sub.cancel();
await sse.close();
```

## Field Matching Semantics

The client supports both of these server styles:

1. Custom-field style (non-standard SSE):

```
position-updated: {"x":1,"y":1}

```

Call `listen('position-updated')` to receive that value.

2. Standard SSE style:

```
event: position-updated
data: {"x":1,"y":1}

```

Call `listen('position-updated')` to receive `data`.

## Headers And Cookies

Desktop/mobile (`dart:io`) implementation supports passing headers and cookies.

Web (`EventSource`) limitation:
- Cannot set custom headers from browser `EventSource`.
- Cookie behavior depends on browser+CORS policy.
- `listen(fieldKey)` on web treats `fieldKey` as the SSE **event name** and parses the event `.data`.

## Last-Event-ID (Resume)

IO client supports standard SSE resume via `Last-Event-ID` header:
- If the server sends `id: <value>` fields, the client remembers the latest id and re-sends it on reconnect.
- You can also set an initial id with `SseClientOptions.initialLastEventId`.
- Set `SseClientOptions.sendLastEventIdHeader = false` to disable.

On web, `EventSource` manages reconnection internally; custom headers (including `Last-Event-ID`) cannot be set manually.

## sse_incremental_id_mismatch

If your server uses numeric incremental `id:` (e.g. `id: 1`, `id: 2`, ...), you can enable mismatch detection:

```dart
final sse = SseClient(SseClientOptions(
  url: Uri.parse('https://example.com/sse'),
  enableSseIncrementalIdMismatch: true,
  sseIncrementalMismatchCallback: (m) {
    // m.expectedId, m.actualIdRaw, m.reason, m.frame
  },
));
```

Semantics (IO client):
- First received frame MUST include a numeric `id:`; otherwise the client reports an error and closes ("don’t continue").
- After that, each next frame is expected to have `id == previous + 1`. If not, the callback is invoked.
- On mismatch where an unexpected numeric id is observed, the validator resyncs to that observed id and continues checking future increments.

Web: this is not enforced (the web client uses `EventSource` and does not currently validate incremental ids).

## Reconnect

`SseClientOptions.autoReconnect` retries when the TCP stream closes or errors.

## Implementation Notes

- Parser: `lib/sse_client/src/sse_parser.dart` turns the byte stream into blank-line-delimited `SseFrame`s.
- Extraction: `listen(fieldKey)` first looks for a direct `<fieldKey>: ...` field in the frame; if absent it falls back to standard SSE semantics where `event == fieldKey` and uses `data`.
