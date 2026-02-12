class CreateServerPropertiesRequest {
  late final String serviceName;
  late final String tag;
  late final String serverAddress;

  // Optional: Keycloak / OIDC config
  final String keycloakBaseUrl;
  final String keycloakRealm;
  final String keycloakClientId;

  CreateServerPropertiesRequest({
    required this.serviceName,
    required this.tag,
    required this.serverAddress,
    this.keycloakBaseUrl = '',
    this.keycloakRealm = '',
    this.keycloakClientId = '',
  });
}
