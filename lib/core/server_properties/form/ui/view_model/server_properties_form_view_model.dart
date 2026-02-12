import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/model/process_state.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/create_server_properties_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/update_service_by_name_request.dart';

class ServerPropertiesFormViewModel extends ChangeNotifier {
  // Deps
  late final ServerPropertiesRegistryService _registryService;
  late final String _serviceName;
  late final String _tag;

  // State
  final formKey = GlobalKey<FormState>();
  final TextEditingController serverAddress = TextEditingController();
  final TextEditingController keycloakBaseUrl = TextEditingController();
  final TextEditingController keycloakRealm = TextEditingController();
  final TextEditingController keycloakClientId = TextEditingController();
  ProcessState saveState = ProcessState(state: ProcessStateEnum.none);
  bool _disposed = false;
  int _loadEpoch = 0;

  ServerPropertiesFormViewModel({
    required ServerPropertiesRegistryService registryService,
    required String serviceName,
    required String tag,
  }) {
    _registryService = registryService;
    _serviceName = serviceName;
    _tag = tag;
  }

  void init() {
    unawaited(loadByServiceName());
  }

  Future<void> loadByServiceName() async {
    if (_disposed) return;
    final loadEpoch = ++_loadEpoch;
    ServerProperty? serverProperty = await _registryService
        .getOneByServiceNameAndTag(serviceName: _serviceName, tag: _tag);
    if (_disposed || loadEpoch != _loadEpoch) return;
    if (serverProperty != null) {
      serverAddress.text = serverProperty.serverAddress;
      keycloakBaseUrl.text = serverProperty.keycloakBaseUrl;
      keycloakRealm.text = serverProperty.keycloakRealm;
      keycloakClientId.text = serverProperty.keycloakClientId;
    }
  }

  Future<void> save() async {
    if (_disposed) return;
    final serverAddressValue = serverAddress.text;
    final keycloakBaseUrlValue = keycloakBaseUrl.text;
    final keycloakRealmValue = keycloakRealm.text;
    final keycloakClientIdValue = keycloakClientId.text;

    try {
      _setSaveState(ProcessState(state: ProcessStateEnum.loading));

      ServerProperty? serverProperty = await _registryService
          .getOneByServiceNameAndTag(serviceName: _serviceName, tag: _tag);
      if (_disposed) return;
      if (serverProperty == null) {
        await _registryService.create(
          CreateServerPropertiesRequest(
            serviceName: _serviceName,
            tag: _tag,
            serverAddress: serverAddressValue,
            keycloakBaseUrl: keycloakBaseUrlValue,
            keycloakRealm: keycloakRealmValue,
            keycloakClientId: keycloakClientIdValue,
          ),
        );
      } else {
        await _registryService.updateByServiceNameAndTag(
          UpdateServiceByNameRequest(
            serviceName: _serviceName,
            tag: _tag,
            serverAddress: serverAddressValue,
            keycloakBaseUrl: keycloakBaseUrlValue,
            keycloakRealm: keycloakRealmValue,
            keycloakClientId: keycloakClientIdValue,
          ),
        );
      }

      _setSaveState(ProcessState(state: ProcessStateEnum.success));
    } on Exception catch (ex) {
      _setSaveState(
        ProcessState(
          state: ProcessStateEnum.failed,
          errorMessage: ex.toString(),
        ),
      );
    } finally {
      if (!_disposed) {
        _setSaveState(
          ProcessState(
            state: ProcessStateEnum.none,
            errorMessage: saveState.errorMessage,
          ),
        );
      }
    }
  }

  void _setSaveState(ProcessState next) {
    if (_disposed) return;
    saveState = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _loadEpoch++; // invalidates any in-flight loadByServiceName completion
    serverAddress.dispose();
    keycloakBaseUrl.dispose();
    keycloakRealm.dispose();
    keycloakClientId.dispose();
    super.dispose();
  }
}
