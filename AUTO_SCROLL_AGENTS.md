# Auto Scroll Agent Notes

Reusable vertical auto-scroll utility for Flutter scrollable views.

## Source

- `lib/core/utility/looping_vertical_auto_scroll.dart`

## Contract

- `AutoScrollCoordinator` (interface)
  - `attach()`: start lifecycle hooks (includes metric observer)
  - `detach()`: stop hooks and timers
  - `scheduleSync()`: defer sync to next frame
  - `syncNow()`: start/stop auto-scroll immediately based on scroll state
  - `onScrollMetricsChanged()`: notify coordinator that metrics changed

## Default Implementation

- `LoopingVerticalAutoScrollCoordinator`
  - manages a target `ScrollController`
  - auto-scrolls downward by `step` on every `tickDuration`
  - loops back to offset `0` after reaching bottom
  - reacts to window/layout metrics changes through `WidgetsBindingObserver`
  - can disable hard reset with `resetToStartWhenAtMaxExtent: false`

## Extension Points

- Implement `AutoScrollCoordinator` for fully custom behavior.
- Use `LoopingVerticalAutoScrollCoordinator` with callback overrides:
  - `shouldRun`: custom condition for start/stop
  - `nextOffset`: custom offset progression per tick

## Infinite Loop Strategy

- For seamless "infinite" vertical scrolling on finite data:
  - render repeated row copies (commonly `3x`)
  - provide `nextOffset` that wraps by one cycle extent before reaching the end
  - wrap a few rows before bottom (for example `2-3` rows) to avoid visible hitch
  - this avoids visible reset to offset `0`

## Integration Pattern

1. Create the widget's `ScrollController`.
2. Create a coordinator in `initState` and call `attach()`.
3. Call `scheduleSync()` in `build()` or after data changes.
4. Forward `ScrollMetricsNotification` to `onScrollMetricsChanged()`.
5. Call `detach()` in `dispose()`.

## Example

```dart
late final ScrollController _verticalController;
late final AutoScrollCoordinator _autoScroll;

@override
void initState() {
  super.initState();
  _verticalController = ScrollController();
  _autoScroll = LoopingVerticalAutoScrollCoordinator(
    controller: _verticalController,
    step: 0.3,
  )..attach();
}

@override
void dispose() {
  _autoScroll.detach();
  _verticalController.dispose();
  super.dispose();
}
```
