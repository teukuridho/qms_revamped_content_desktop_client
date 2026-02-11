import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/view_model/auth_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view/server_properties_form_view.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class ServerPropertiesConfigurationDialog extends StatefulWidget {
  final String serviceName;
  final String title;
  final String description;
  final ServerPropertiesRegistryService registryService;
  final EventManager eventManager;
  final Key? dialogKey;

  const ServerPropertiesConfigurationDialog({
    super.key,
    required this.serviceName,
    required this.title,
    required this.description,
    required this.registryService,
    required this.eventManager,
    this.dialogKey,
  });

  @override
  State<ServerPropertiesConfigurationDialog> createState() =>
      _ServerPropertiesConfigurationDialogState();
}

class _ServerPropertiesConfigurationDialogState
    extends State<ServerPropertiesConfigurationDialog> {
  late final ServerPropertiesFormViewModel _formViewModel =
      ServerPropertiesFormViewModel(
        registryService: widget.registryService,
        serviceName: widget.serviceName,
      );

  late final AuthViewModel _authViewModel = AuthViewModel(
    authService: OidcAuthService(
      serviceName: widget.serviceName,
      serverPropertiesRegistryService: widget.registryService,
      eventManager: widget.eventManager,
    ),
  );

  @override
  void dispose() {
    _formViewModel.dispose();
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: widget.dialogKey,
      child: SizedBox(
        width: 640,
        height: 760,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.description),
              const SizedBox(height: 12),
              Expanded(
                child: ServerPropertiesFormView(
                  viewModel: _formViewModel,
                  authViewModel: _authViewModel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
