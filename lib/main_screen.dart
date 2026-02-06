import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/form/ui/screen/server_properties_form_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return ServerPropertiesFormScreen();
  }
}
