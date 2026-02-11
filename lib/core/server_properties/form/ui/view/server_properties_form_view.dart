import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/auth_section.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/ui/view_model/auth_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/model/process_state.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/core/utility/selector.dart';

class ServerPropertiesFormView extends StatefulWidget {
  final ServerPropertiesFormViewModel viewModel;
  final AuthViewModel? authViewModel;

  const ServerPropertiesFormView({
    super.key,
    required this.viewModel,
    this.authViewModel,
  });

  @override
  State<ServerPropertiesFormView> createState() =>
      _ServerPropertiesFormViewState();
}

class _ServerPropertiesFormViewState extends State<ServerPropertiesFormView> {
  late final VoidCallback _cancelSaveErrorListener;
  ScaffoldMessengerState? _messenger;

  @override
  void initState() {
    super.initState();
    widget.viewModel.init();
    _attachListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.maybeOf(context);
  }

  void _attachListeners() {
    _cancelSaveErrorListener = listenTo(
      widget.viewModel,
      () => widget.viewModel.saveState,
      (saveState) {
        if (!mounted) return;
        final messenger = _messenger;
        if (messenger == null || !messenger.mounted) return;

        switch (saveState.state) {
          case ProcessStateEnum.none:
            return;
          case ProcessStateEnum.loading:
            messenger.showSnackBar(SnackBar(content: Text("Loading...")));
            return;
          case ProcessStateEnum.success:
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: Text("Success!"),
                backgroundColor: Colors.green,
              ),
            );
            return;
          case ProcessStateEnum.failed:
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: Text("Unable to proceed; $saveState"),
                backgroundColor: Colors.red,
              ),
            );
            return;
        }
      },
    );
  }

  @override
  void dispose() {
    _cancelSaveErrorListener();
    super.dispose();
  }

  void _handleButtonSubmit() {
    bool valid = widget.viewModel.formKey.currentState!.validate();
    if (valid) {
      widget.viewModel.save();
    }
  }

  void _handleSubmitByEnter(String _) {
    _handleButtonSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.viewModel.formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: widget.viewModel.serverAddress,
            onFieldSubmitted: _handleSubmitByEnter,
            decoration: InputDecoration(
              labelText: "Server Address",
              border: OutlineInputBorder(),
              hintText: "Example: http://localhost:8081. DO NOT end with /",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter some text";
              }
              return null;
            },
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          TextFormField(
            controller: widget.viewModel.keycloakBaseUrl,
            decoration: const InputDecoration(
              labelText: "Keycloak Base URL",
              border: OutlineInputBorder(),
              hintText: "Example: https://id.example.com (no trailing /)",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          TextFormField(
            controller: widget.viewModel.keycloakRealm,
            decoration: const InputDecoration(
              labelText: "Keycloak Realm",
              border: OutlineInputBorder(),
              hintText: "Example: master",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          TextFormField(
            controller: widget.viewModel.keycloakClientId,
            decoration: const InputDecoration(
              labelText: "Keycloak Client ID",
              border: OutlineInputBorder(),
              hintText: "Example: qms-desktop-client",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: _handleButtonSubmit,
              child: Text("Submit"),
            ),
          ),
          if (widget.authViewModel != null) ...[
            Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
            AuthSection(viewModel: widget.authViewModel!),
          ],
        ],
      ),
    );
  }
}
