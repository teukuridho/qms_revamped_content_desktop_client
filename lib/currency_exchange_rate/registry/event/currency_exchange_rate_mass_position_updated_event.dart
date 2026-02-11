import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';

class CurrencyExchangeRateMassPositionUpdatedEvent {
  late final List<RecordWithPosition> list;

  CurrencyExchangeRateMassPositionUpdatedEvent({required this.list});
}
