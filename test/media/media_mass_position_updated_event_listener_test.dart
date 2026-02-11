import 'package:flutter_test/flutter_test.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_reload_signal.dart';
import 'package:qms_revamped_content_desktop_client/media/position_update/media_mass_position_updated_event_listener.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_mass_position_updated_event.dart';

class _FakeReloadSignal implements MediaReloadSignal {
  int calls = 0;

  @override
  void markReloadNeeded() {
    calls += 1;
  }
}

void main() {
  test(
    'marks reload needed when MediaMassPositionUpdatedEvent is received',
    () async {
      final eventManager = EventManager()..init();
      final reloadSignal = _FakeReloadSignal();

      final listener = MediaMassPositionUpdatedEventListener(
        serviceName: 'service-a',
        tag: 'main',
        eventManager: eventManager,
        reloadSignal: reloadSignal,
      )..init();

      eventManager.publishEvent(
        MediaMassPositionUpdatedEvent(
          list: [RecordWithPosition(id: 1, position: 2)],
        ),
      );
      eventManager.publishEvent(
        MediaMassPositionUpdatedEvent(
          list: [RecordWithPosition(id: 2, position: 3)],
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(reloadSignal.calls, 2);

      await listener.dispose();
    },
  );
}
