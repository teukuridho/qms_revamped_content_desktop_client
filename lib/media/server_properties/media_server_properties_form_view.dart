import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_form_view.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class MediaServerPropertiesFormView extends ServerPropertiesFormView {
  MediaServerPropertiesFormView({
    super.key,
    required ServerPropertiesRegistryService registryService,
  }) : super(
         viewModel: ServerPropertiesFormViewModel(
           registryService: registryService,
           serviceName: "media",
           tag: "main",
         ),
       );
}
