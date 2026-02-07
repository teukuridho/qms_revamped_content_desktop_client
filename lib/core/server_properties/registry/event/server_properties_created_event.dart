
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';

class ServerPropertiesCreatedEvent {
  late final ServerProperty serverProperty;

  ServerPropertiesCreatedEvent(this.serverProperty);
}