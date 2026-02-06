import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/form/ui/view/server_properties_form_view.dart';

class ServerPropertiesFormScreen extends StatefulWidget {
  const ServerPropertiesFormScreen({super.key});

  @override
  State<ServerPropertiesFormScreen> createState() => _ServerPropertiesFormScreenState();
}

class _ServerPropertiesFormScreenState extends State<ServerPropertiesFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        child: ServerPropertiesFormView(),
      ),
    );
  }
}
