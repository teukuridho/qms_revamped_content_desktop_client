import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';

class MediaMassPositionUpdatedEvent {
  late final List<RecordWithPosition> list;

  MediaMassPositionUpdatedEvent({required this.list});
}