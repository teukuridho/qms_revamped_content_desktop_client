class LogRedactor {
  static final RegExp _bearer = RegExp(
    r'\bBearer\s+([A-Za-z0-9._~-]+)',
    caseSensitive: false,
  );
  static final RegExp _jwt = RegExp(
    r'([A-Za-z0-9_-]{10,})\.([A-Za-z0-9_-]{10,})\.([A-Za-z0-9_-]{10,})',
  );

  static final List<RegExp> _kvPatterns = <RegExp>[
    RegExp(
      r'\b(access_token|refresh_token|id_token|token|client_secret|secret|password)\b\s*[:=]\s*([^\s,;]+)',
      caseSensitive: false,
    ),
  ];

  static String redact(String input) {
    var out = input;

    // Authorization: Bearer <token>
    out = out.replaceAllMapped(_bearer, (m) => 'Bearer <redacted>');

    // Mask obvious JWTs anywhere in the message.
    out = out.replaceAllMapped(_jwt, (_) => '<redacted.jwt>');

    // Mask common key/value token patterns.
    for (final p in _kvPatterns) {
      out = out.replaceAllMapped(p, (m) => '${m.group(1)}=<redacted>');
    }

    return out;
  }
}
