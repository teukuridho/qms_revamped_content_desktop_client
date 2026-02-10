class AuthStatus {
  final String serviceName;

  final bool hasConfig;
  final bool hasAccessToken;
  final bool hasRefreshToken;

  /// 0 means unknown / not set.
  final int accessTokenExpiresAtEpochMs;

  /// Local-only check based on stored expiry timestamp.
  final bool accessTokenIsExpired;

  const AuthStatus({
    required this.serviceName,
    required this.hasConfig,
    required this.hasAccessToken,
    required this.hasRefreshToken,
    required this.accessTokenExpiresAtEpochMs,
    required this.accessTokenIsExpired,
  });

  bool get isLoggedIn => hasAccessToken || hasRefreshToken;
}
