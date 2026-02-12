import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';

class ProductCreatedEvent {
  late final Product product;

  ProductCreatedEvent({required this.product});
}
