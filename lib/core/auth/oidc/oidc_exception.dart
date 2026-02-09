class OidcOAuthException implements Exception {
  final String error;
  final String? errorDescription;

  const OidcOAuthException(this.error, {this.errorDescription});

  @override
  String toString() {
    final d = errorDescription;
    if (d == null || d.isEmpty) return 'OidcOAuthException($error)';
    return 'OidcOAuthException($error, $d)';
  }
}

class OidcProtocolException implements Exception {
  final String message;
  const OidcProtocolException(this.message);

  @override
  String toString() => 'OidcProtocolException($message)';
}

