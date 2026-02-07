import 'package:flutter/material.dart';

typedef ShouldRebuild<T> = bool Function(T previous, T next);

/// Attaches a listener to [notifier] and calls [callback] only when the value
/// returned by [selector] changes.
///
/// Returns a [VoidCallback] that must be called to detach the listener.
VoidCallback listenTo<T>(
  Listenable notifier,
  T Function() selector,
  void Function(T next) callback, {
  ShouldRebuild<T>? shouldNotify,
}) {
  T last = selector();

  void listener() {
    final current = selector();
    final changed = shouldNotify?.call(last, current) ?? (current != last);
    if (!changed) return;

    last = current;
    callback(current);
  }

  notifier.addListener(listener);
  return () => notifier.removeListener(listener);
}

/// A lightweight "selector widget" for any [Listenable] (e.g. [ChangeNotifier]).
///
/// It rebuilds only when the selected value changes, similar to `provider`'s
/// `Selector`, but without requiring the notifier to be provided via context.
class WidgetSelector<N extends Listenable, S> extends StatefulWidget {
  final N listenable;
  final S Function(BuildContext context, N listenable) selector;
  final Widget Function(BuildContext context, S value, Widget? child) builder;
  final Widget? child;
  final ShouldRebuild<S>? shouldRebuild;

  const WidgetSelector({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
    this.child,
    this.shouldRebuild,
  });

  @override
  State<WidgetSelector<N, S>> createState() => _WidgetSelectorState<N, S>();
}

class _WidgetSelectorState<N extends Listenable, S>
    extends State<WidgetSelector<N, S>> {
  late S _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selector(context, widget.listenable);
    widget.listenable.addListener(_handleListenableChanged);
  }

  @override
  void didUpdateWidget(covariant WidgetSelector<N, S> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.listenable, widget.listenable)) {
      oldWidget.listenable.removeListener(_handleListenableChanged);
      widget.listenable.addListener(_handleListenableChanged);
    }

    // Ensure we re-select if the selector changes or if the listenable changes.
    _selected = widget.selector(context, widget.listenable);
  }

  void _handleListenableChanged() {
    if (!mounted) return;
    final next = widget.selector(context, widget.listenable);
    final shouldRebuild =
        widget.shouldRebuild?.call(_selected, next) ?? (next != _selected);
    if (!shouldRebuild) return;

    setState(() {
      _selected = next;
    });
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_handleListenableChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _selected, widget.child);
  }
}
