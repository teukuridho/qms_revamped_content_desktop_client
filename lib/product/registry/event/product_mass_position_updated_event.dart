import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';

class ProductMassPositionUpdatedEvent {
  late final List<RecordWithPosition> list;

  ProductMassPositionUpdatedEvent({required this.list});
}
