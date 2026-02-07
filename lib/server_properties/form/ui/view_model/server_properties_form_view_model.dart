import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/registry/request/create_server_properties_request.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/server_properties/registry/service/update_service_by_name_request.dart';

class ServerPropertiesFormViewModel extends ChangeNotifier {
  // Deps
  late final ServerPropertiesRegistryService _registryService;
  late final String _serviceName;

  // State
  final formKey = GlobalKey<FormState>();
  final TextEditingController serverAddress = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool saveLoading = false;
  String? saveError;
  bool? saveSuccess;

  ServerPropertiesFormViewModel({
    required ServerPropertiesRegistryService registryService,
    required String serviceName,
  }) {
    _registryService = registryService;
    _serviceName = serviceName;
  }

  void init() {
    loadByServiceName();
  }

  Future<void> loadByServiceName() async {
    ServerProperty? serverProperty = await _registryService.getOneByServiceName(
      serviceName: _serviceName,
    );
    if (serverProperty != null) {
      serverAddress.text = serverProperty.serverAddress;
      username.text = serverProperty.username;
      password.text = serverProperty.password;
    }
  }

  Future<void> save() async {
    try {
      saveLoading = true;
      notifyListeners();

      ServerProperty? serverProperty = await _registryService
          .getOneByServiceName(serviceName: _serviceName);
      if (serverProperty == null) {
        _registryService.create(
          CreateServerPropertiesRequest(
            serviceName: _serviceName,
            serverAddress: serverAddress.text,
            username: username.text,
            password: password.text,
          ),
        );
      } else {
        _registryService.updateByServiceName(
          UpdateServiceByNameRequest(
            serviceName: _serviceName,
            username: username.text,
            password: password.text,
            serverAddress: serverAddress.text,
          ),
        );
      }

      saveSuccess = true;
      notifyListeners();
    } on Exception catch (ex) {
      saveError = ex.toString();
    } finally {
      saveLoading = false;
      notifyListeners();
    }
  }
}
