import 'dart:async';

import 'package:flutter/widgets.dart';

typedef AutoScrollShouldRun = bool Function(ScrollPosition position);
typedef AutoScrollNextOffset =
    double Function(ScrollPosition position, double step);

/// Contract for reusable auto-scroll coordinators.
abstract class AutoScrollCoordinator {
  void attach();
  void detach();
  void scheduleSync();
  void syncNow();
  void onScrollMetricsChanged();
}

/// Auto-scrolls a vertical [ScrollController] and loops back to top.
///
/// Behavior:
/// - Starts only when [shouldRun] returns true (default: content overflows).
/// - Moves down by [step] every [tickDuration].
/// - When it reaches bottom, it jumps back to offset `0`.
/// - Reacts to layout metric changes (e.g. window resize).
class LoopingVerticalAutoScrollCoordinator
    with WidgetsBindingObserver
    implements AutoScrollCoordinator {
  final ScrollController controller;
  final Duration tickDuration;
  final double step;
  final AutoScrollShouldRun? shouldRun;
  final AutoScrollNextOffset? nextOffset;

  Timer? _timer;
  bool _attached = false;
  bool _syncScheduled = false;

  LoopingVerticalAutoScrollCoordinator({
    required this.controller,
    this.tickDuration = const Duration(milliseconds: 32),
    this.step = 1.2,
    this.shouldRun,
    this.nextOffset,
  }) : assert(step > 0, 'Auto-scroll step must be > 0');

  @override
  void attach() {
    if (_attached) return;
    _attached = true;
    WidgetsBinding.instance.addObserver(this);
    scheduleSync();
  }

  @override
  void detach() {
    if (!_attached) return;
    _attached = false;
    WidgetsBinding.instance.removeObserver(this);
    _syncScheduled = false;
    _stop();
  }

  @override
  void didChangeMetrics() {
    scheduleSync();
  }

  @override
  void onScrollMetricsChanged() {
    scheduleSync();
  }

  @override
  void scheduleSync() {
    if (!_attached || _syncScheduled) return;
    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!_attached) return;
      syncNow();
    });
  }

  @override
  void syncNow() {
    if (!_attached || !controller.hasClients) {
      _stop();
      return;
    }

    final position = controller.position;
    final canRun = shouldRun?.call(position) ?? (position.maxScrollExtent > 0);
    if (canRun) {
      _start();
      return;
    }

    _stop();
  }

  void _start() {
    if (_timer != null) return;

    _timer = Timer.periodic(tickDuration, (_) {
      if (!_attached || !controller.hasClients) {
        _stop();
        return;
      }

      final position = controller.position;
      final maxExtent = position.maxScrollExtent;
      final canRun = shouldRun?.call(position) ?? (maxExtent > 0);
      if (!canRun || maxExtent <= 0) {
        _stop();
        return;
      }

      final rawNext =
          nextOffset?.call(position, step) ?? (position.pixels + step);
      final clamped = rawNext.clamp(0, maxExtent).toDouble();
      final next = clamped >= maxExtent ? 0.0 : clamped;
      if (next == position.pixels) return;

      controller.jumpTo(next);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }
}
