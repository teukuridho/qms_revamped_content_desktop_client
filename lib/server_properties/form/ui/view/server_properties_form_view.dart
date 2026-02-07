import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/form/ui/view_model/server_properties_form_view_model.dart';
import 'package:qms_revamped_content_desktop_client/utility/selector.dart';

class ServerPropertiesFormView extends StatefulWidget {
  final ServerPropertiesFormViewModel viewModel;

  const ServerPropertiesFormView({super.key, required this.viewModel});

  @override
  State<ServerPropertiesFormView> createState() =>
      _ServerPropertiesFormViewState();
}

class _ServerPropertiesFormViewState extends State<ServerPropertiesFormView> {
  @override
  void initState() {
    widget.viewModel.init();
    _attachListeners();
    super.initState();
  }

  void _attachListeners() {
    listenTo(widget.viewModel, () => widget.viewModel.saveError, (saveError) {
      if(saveError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to proceed; $saveError}"),
            backgroundColor: Colors.red,),
        );
      }
    });
    listenTo(widget.viewModel, () => widget.viewModel.saveSuccess, (saveSuccess) {
      if(saveSuccess != null && saveSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Success!"),  backgroundColor: Colors.green,),
        );
      }
    });
    // widget.viewModel.addListener(() {
    //   String? saveError = widget.viewModel.saveError;
    //   bool? saveSuccess = widget.viewModel.saveSuccess;
    //   if(saveError != null) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Unable to proceed; $saveError}"),  backgroundColor: Colors.red,),
    //     );
    //   }
    //   if(saveSuccess != null && saveSuccess) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Success!"),  backgroundColor: Colors.green,),
    //     );
    //   }
    // });
  }

  void _handleSubmit() {
    bool valid = widget.viewModel.formKey.currentState!.validate();
    if(valid) {
      widget.viewModel.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.viewModel.formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: widget.viewModel.serverAddress,
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
            child: ElevatedButton(onPressed: _handleSubmit, child: Text("Submit")),
          ),
        ],
      ),
    );
  }
}
