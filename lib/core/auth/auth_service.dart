import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';

class AuthService {
  late final String _serviceName;
  late final ServerPropertiesRegistryService _serverPropertiesRegistryService;

  AuthService({required String serviceName, required ServerPropertiesRegistryService serverPropertiesRegistryService}) {
    _serviceName = serviceName;
    _serverPropertiesRegistryService = serverPropertiesRegistryService;
  }

  void login() {
    
  }
}