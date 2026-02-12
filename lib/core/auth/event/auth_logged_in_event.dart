class AuthLoggedInEvent {
  final String serviceName;
  final String tag;

  /// `browser_pkce` or `device_qr`
  final String method;

  final int loggedInAtEpochMs;

  final String keycloakBaseUrl;
  final String keycloakRealm;
  final String keycloakClientId;

  final String scope;
  final String tokenType;
  final int accessTokenExpiresAtEpochMs;
  final bool hasRefreshToken;

  const AuthLoggedInEvent({
    required this.serviceName,
    required this.tag,
    required this.method,
    required this.loggedInAtEpochMs,
    required this.keycloakBaseUrl,
    required this.keycloakRealm,
    required this.keycloakClientId,
    required this.scope,
    required this.tokenType,
    required this.accessTokenExpiresAtEpochMs,
    required this.hasRefreshToken,
  });
}
