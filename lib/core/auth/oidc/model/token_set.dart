class OidcTokenSet {
  final String accessToken;
  final String refreshToken;
  final String idToken;
  final DateTime expiresAt;
  final String scope;
  final String tokenType;

  const OidcTokenSet({
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.expiresAt,
    required this.scope,
    required this.tokenType,
  });

  int get expiresAtEpochMs => expiresAt.millisecondsSinceEpoch;
}

