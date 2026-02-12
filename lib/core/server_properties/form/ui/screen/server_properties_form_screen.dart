import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/view_model/auth_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/config/app_config.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_form_view.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class ServerPropertiesFormScreen extends StatefulWidget {
  final ServerPropertiesRegistryService registryService;
  final EventManager eventManager;

  const ServerPropertiesFormScreen({
    super.key,
    required this.registryService,
    required this.eventManager,
  });

  @override
  State<ServerPropertiesFormScreen> createState() =>
      _ServerPropertiesFormScreenState();
}

class _ServerPropertiesFormScreenState
    extends State<ServerPropertiesFormScreen> {
  late final ServerPropertiesFormViewModel viewModel =
      ServerPropertiesFormViewModel(
        registryService: widget.registryService,
        serviceName: AppConfig.serviceName,
        tag: AppConfig.positionUpdateTag,
      );

  late final AuthViewModel authViewModel = AuthViewModel(
    authService: OidcAuthService(
      serviceName: AppConfig.serviceName,
      tag: AppConfig.positionUpdateTag,
      serverPropertiesRegistryService: widget.registryService,
      eventManager: widget.eventManager,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Just a test
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ServerPropertiesFormView(
          viewModel: viewModel,
          authViewModel: authViewModel,
        ),
      ),
    );
  }
}
