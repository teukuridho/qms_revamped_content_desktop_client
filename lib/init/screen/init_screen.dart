import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qms_revamped_content_desktop_client/init/view_model/init_view_model.dart';
import 'package:qms_revamped_content_desktop_client/main_screen.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/utility/selector.dart';

class InitScreen extends StatefulWidget {
  final ServerPropertiesRegistryService serverPropertiesRegistryService;
  final InitViewModel model;

  const InitScreen({super.key, required this.model, required this.serverPropertiesRegistryService});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  late final VoidCallback _cancelFinishedListener;

  @override
  void initState() {
    final model = Provider.of<InitViewModel>(context, listen: false);
    _cancelFinishedListener = listenTo<bool>(
      model,
      () => model.finished,
      (success) {
        if (!mounted) return;
        if (!success) return;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              registryService: widget.serverPropertiesRegistryService,
            ),
          ),
        );
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _cancelFinishedListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Selector<InitViewModel, String>(
          selector: (_, provider) => provider.message,
          builder: (context, value, child) {
            return Text(value);
          },
        ),
      ),
    );
  }
}
