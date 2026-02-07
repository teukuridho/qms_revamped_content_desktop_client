import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/model/process_state.dart';
import 'package:qms_revamped_content_desktop_client/core/utility/selector.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/form/ui/view_model/server_properties_form_view_model.dart';

class ServerPropertiesFormView extends StatefulWidget {
  final ServerPropertiesFormViewModel viewModel;

  const ServerPropertiesFormView({super.key, required this.viewModel});

  @override
  State<ServerPropertiesFormView> createState() =>
      _ServerPropertiesFormViewState();
}

class _ServerPropertiesFormViewState extends State<ServerPropertiesFormView> {
  late final VoidCallback _cancelSaveErrorListener;

  @override
  void initState() {
    widget.viewModel.init();
    _attachListeners();
    super.initState();
  }

  void _attachListeners() {
    _cancelSaveErrorListener =
        listenTo(widget.viewModel, () => widget.viewModel.saveState, (saveState) {
      if (!mounted) return;

      switch(saveState.state) {
        case ProcessStateEnum.none:
          return;
        case ProcessStateEnum.loading:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Loading..."),
            ),
          );
        case ProcessStateEnum.success:
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Success!"),
              backgroundColor: Colors.green,
            ),
          );
        case ProcessStateEnum.failed:
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unable to proceed; $saveState"),
              backgroundColor: Colors.red,
            ),
          );
      }
    });
  }

  @override
  void dispose() {
    _cancelSaveErrorListener();
    super.dispose();
  }

  void _handleButtonSubmit() {
    bool valid = widget.viewModel.formKey.currentState!.validate();
    if(valid) {
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
            controller: widget.viewModel.username,
            onFieldSubmitted: _handleSubmitByEnter,
            decoration: InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
              hintText: "Example: admin",
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
            controller: widget.viewModel.password,
            onFieldSubmitted: _handleSubmitByEnter,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
              hintText: "Example: admin",
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
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(
                onPressed: _handleButtonSubmit, child: Text("Submit")),
          ),
        ],
      ),
    );
  }
}
