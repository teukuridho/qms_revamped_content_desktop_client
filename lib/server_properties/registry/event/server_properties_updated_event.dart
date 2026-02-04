import 'package:qms_revamped_content_desktop_client/database/app_database.dart';

class ServerPropertiesUpdatedEvent {
  late final ServerProperty serverProperty;

  ServerPropertiesUpdatedEvent(this.serverProperty);
}