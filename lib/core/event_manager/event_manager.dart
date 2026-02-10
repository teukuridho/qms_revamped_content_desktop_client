import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

class EventManager {
  static final AppLog _log = AppLog('event_manager');

  late final EventBus _eventBus;

  void init() {
    _eventBus = EventBus();
    _log.i('EventBus initialized');
  }

  void publishEvent(dynamic event) {
    if (kDebugMode) {
      _log.d('publishEvent(${event.runtimeType})');
    }
    _eventBus.fire(event);
  }

  Stream<T> listen<T>() {
    if (kDebugMode) {
      _log.d('listen<$T>()');
    }
    return _eventBus.on<T>();
  }
}
