# Logging (Agent Notes)

This project uses a small logging layer under `lib/core/logging/` to:

- capture and format logs consistently across the app
- redact common secrets (tokens/passwords) from log messages
- write logs both to the developer console and (on IO platforms) to a log file
- capture uncaught Flutter / platform / zone errors

## Where Logs Go

1. **Developer console sink (always)**
   - Implemented by `DeveloperLogSink` (`lib/core/logging/developer_log_sink.dart`)
   - Uses `dart:developer.log(...)` so logs show up in `flutter run`, IDE debug console, and DevTools.

2. **File sink (IO platforms only)**
   - Implemented by `FileLogSink` (`lib/core/logging/file_log_sink.dart`)
   - Enabled in `LoggingBootstrap.init()` (best-effort; failures never crash the app).
   - Writes to:
     - `<ApplicationSupportDirectory>/logs/app.log`
     - This is resolved by `path_provider` at runtime (platform-specific location).
   - On web, the file sink is a no-op stub (`lib/core/logging/file_log_sink_stub.dart`).

At startup, the bootstrap logger prints whether file logging is enabled and the resolved file path:

- `lib/core/logging/logging_bootstrap.dart`
- called from `lib/main.dart`

## File Format + Rotation

- Each record is written as:
  - `[ISO_TIMESTAMP][LEVEL][LOGGER_NAME] message | error=...`
  - stack traces are appended on the next line
- Rotation:
  - when `app.log` exceeds **5 MiB**, it is rotated to `app.log.1`
  - up to **2** backups are kept (`app.log.1`, `app.log.2`)
  - rotation is best-effort

## Redaction / Safety

Redaction is enabled by default (`AppLogConfig.redactSecrets = true`).

`LogRedactor` (`lib/core/logging/log_redactor.dart`) masks common secret patterns in log messages, including:

- `Bearer <token>` (Authorization headers)
- JWT-like strings
- key/value tokens such as `access_token=...`, `refresh_token=...`, `password=...`

Important: the code avoids emitting raw tokens in events and most logs, but redaction is a last line of defense.

## How Logging Is Initialized

`lib/main.dart` does:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await LoggingBootstrap.init()`
3. wraps `runApp(...)` in `LoggingBootstrap.runZoned(...)`

`LoggingBootstrap.init()` additionally registers:

- `FlutterError.onError` handler
- `PlatformDispatcher.instance.onError` handler

So uncaught errors get logged.

## How To Log In Code

Use `AppLog`:

```dart
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

final log = AppLog('feature_name');

log.d('debug message');
log.i('info message');
log.w('warn message');
log.e('error message', error: e, stackTrace: st);
```

Logger names are free-form strings. Prefer stable, dot-separated components, e.g. `AppLog('auth.oidc')`.

## What Was Wired Up (Current Coverage)

- App bootstrap + uncaught errors:
  - `lib/main.dart`
  - `lib/core/logging/logging_bootstrap.dart`
- Core service lifecycle logs:
  - `lib/core/init/service/init_service.dart`
  - `lib/core/app_directory/app_directory_service.dart`
  - `lib/core/database/app_database_manager.dart`
  - `lib/core/event_manager/event_manager.dart` (debug-only noise reduction)
  - `lib/core/server_properties/registry/service/server_properties_registry_service.dart` (token-safe summaries)
- Auth / OIDC flow logs:
  - `lib/core/auth/auth_logger.dart`
  - `lib/core/auth/auth_service.dart`
  - `lib/core/auth/oidc/keycloak_oidc_client.dart`
  - `lib/core/auth/oidc/loopback_server.dart`
- SSE connection logs via a dependency-free callback hook:
  - `lib/sse_client/src/sse_client_base.dart` (`SseClientOptions.logger`)
  - `lib/sse_client/src/sse_client_io.dart`
  - `lib/sse_client/src/sse_client_web.dart`
  - hooked from `lib/core/position_update/subscriber/position_update_subscriber.dart`

## Configuration Knobs

In `lib/core/logging/app_log.dart`:

- `AppLogConfig.minLevel`
  - defaults to `debug` in `kDebugMode`, `info` otherwise
- `AppLogConfig.redactSecrets`
  - defaults to `true`

If you want to change the log file name or rotation rules, update:

- `FileLogSink.tryInit(fileName: ...)`
- constants in `lib/core/logging/file_log_sink.dart`

