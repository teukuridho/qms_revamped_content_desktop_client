# Media Kit Hot Reload Fix

## Context

On Windows debug runs, Flutter hot reload / hot restart could crash with:

`Callback invoked after it has been deleted.`

Related upstream report:
- https://github.com/media-kit/media-kit/issues/1340

Upstream fix PR:
- https://github.com/media-kit/media-kit/pull/1352

## Root Cause (Upstream)

In debug mode, native callback trampolines (`NativeCallable`) could outlive the
Dart isolate lifecycle during hot restart, causing invalid callback invocation.

## Project Fix Applied

We did **not** modify `.pub-cache`.

Instead, we pinned `media_kit` to the upstream PR commit using
`dependency_overrides` in `pubspec.yaml`:

```yaml
dependency_overrides:
  media_kit:
    git:
      url: https://github.com/media-kit/media-kit.git
      ref: 008159a85ed35fb1651d732bf8a20a04a0e1bb1c
      path: media_kit
```

Then ran:

```powershell
flutter pub get
```

Lock confirmation is in `pubspec.lock` under package `media_kit`:
- `source: git`
- `resolved-ref: 008159a85ed35fb1651d732bf8a20a04a0e1bb1c`

## Why This Approach

- No edits to third-party cache directories.
- Fully reproducible in source control.
- Easy rollback when a stable release includes this fix.

## Verify

1. Start app in debug mode on Windows.
2. Trigger hot reload / hot restart while media view is active.
3. Confirm no VM crash with `Callback invoked after it has been deleted`.

## Rollback / Future Cleanup

When `media_kit` publishes a stable release containing this fix:

1. Remove the `dependency_overrides.media_kit` block from `pubspec.yaml`.
2. Keep/upgrade normal semver dependency (`media_kit: ^...`).
3. Run `flutter pub get`.

## Touched Files

- `pubspec.yaml`
- `pubspec.lock`
- `MEDIA_KIT_HOT_RELOAD_FIX_AGENTS.md`
