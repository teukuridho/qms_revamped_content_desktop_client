import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/screen/server_properties_form_screen.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class MainScreen extends StatefulWidget {
  final ServerPropertiesRegistryService registryService;
  const MainScreen({super.key, required this.registryService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return ServerPropertiesFormScreen(registryService: widget.registryService,);
  }
}
