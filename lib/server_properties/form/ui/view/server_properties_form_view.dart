import 'package:flutter/material.dart';

class ServerPropertiesFormView extends StatefulWidget {
  const ServerPropertiesFormView({super.key});

  @override
  State<ServerPropertiesFormView> createState() =>
      _ServerPropertiesFormViewState();
}

class _ServerPropertiesFormViewState extends State<ServerPropertiesFormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: "Server Address",
              border: OutlineInputBorder(),
              hintText: "Example: http://localhost:8081. DO NOT end with /",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          TextFormField(
            decoration: InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
              hintText: "Example: admin",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
              hintText: "Example: admin",
              floatingLabelBehavior: FloatingLabelBehavior.always,
            ),
          ),
          Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10)),
          SizedBox(
            width: double.maxFinite,
            child: ElevatedButton(onPressed: () {}, child: Text("Submit")),
          ),
        ],
      ),
    );
  }
}
