import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/screen/server_properties_form_screen.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {

    // Provider.of<MediaStorageDirectoryService>(context, listen: false).init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ServerPropertiesFormScreen(registryService: Provider.of<ServerPropertiesRegistryService>(context, listen: false),);
  }
}
