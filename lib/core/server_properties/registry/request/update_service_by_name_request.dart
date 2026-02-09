class UpdateServiceByNameRequest {
  late final String serviceName;
  String? serverAddress;

  // Keycloak / OIDC config
  String? keycloakBaseUrl;
  String? keycloakRealm;
  String? keycloakClientId;

  // OIDC tokens
  String? oidcAccessToken;
  String? oidcRefreshToken;
  String? oidcIdToken;
  int? oidcExpiresAtEpochMs;
  String? oidcScope;
  String? oidcTokenType;

  UpdateServiceByNameRequest({
    required this.serviceName,
    this.serverAddress,
    this.keycloakBaseUrl,
    this.keycloakRealm,
    this.keycloakClientId,
    this.oidcAccessToken,
    this.oidcRefreshToken,
    this.oidcIdToken,
    this.oidcExpiresAtEpochMs,
    this.oidcScope,
    this.oidcTokenType,
  });
}
