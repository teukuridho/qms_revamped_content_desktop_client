import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_form_view.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class ServerPropertiesFormScreen extends StatefulWidget {
  final ServerPropertiesRegistryService registryService;

  const ServerPropertiesFormScreen({super.key, required this.registryService});

  @override
  State<ServerPropertiesFormScreen> createState() =>
      _ServerPropertiesFormScreenState();
}

class _ServerPropertiesFormScreenState
    extends State<ServerPropertiesFormScreen> {
  late final ServerPropertiesFormViewModel viewModel =
      ServerPropertiesFormViewModel(
        registryService: widget.registryService,
        serviceName: "test",
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Just a test
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ServerPropertiesFormView(
          viewModel: viewModel,
        ),
      ),
    );
  }
}
