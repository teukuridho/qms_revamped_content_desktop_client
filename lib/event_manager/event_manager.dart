import 'package:event_bus/event_bus.dart';

class EventManager {
  late final EventBus _eventBus;

  void init() {
    _eventBus = EventBus();
  }

  void publishEvent(dynamic event) {
    _eventBus.fire(event);
  }

  Stream<T> listen<T>() {
    return _eventBus.on<T>();
  }
}