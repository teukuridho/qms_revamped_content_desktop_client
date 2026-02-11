import 'dart:async';

import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_reload_signal.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_mass_position_updated_event.dart';

class MediaMassPositionUpdatedEventListener {
  static final AppLog _log = AppLog('media_mass_pos_listener');

  final String serviceName;
  final String tag;
  final EventManager _eventManager;
  final MediaReloadSignal _reloadSignal;

  StreamSubscription<MediaMassPositionUpdatedEvent>? _sub;

  MediaMassPositionUpdatedEventListener({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required MediaReloadSignal reloadSignal,
  }) : _eventManager = eventManager,
       _reloadSignal = reloadSignal;

  void init() {
    _sub ??= _eventManager.listen<MediaMassPositionUpdatedEvent>().listen((
      event,
    ) {
      _log.i(
        'Mass position update received; scheduling media reload at playlist end (serviceName=$serviceName tag=$tag count=${event.list.length})',
      );
      _reloadSignal.markReloadNeeded();
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
