class OidcConfig {
  final String baseUrl;
  final String realm;
  final String clientId;

  const OidcConfig({
    required this.baseUrl,
    required this.realm,
    required this.clientId,
  });
}
