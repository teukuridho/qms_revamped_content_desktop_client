import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PkcePair {
  final String codeVerifier;
  final String codeChallenge;

  const PkcePair({required this.codeVerifier, required this.codeChallenge});

  static PkcePair generate({int verifierByteLength = 64}) {
    final rng = Random.secure();
    final bytes = List<int>.generate(
      verifierByteLength,
      (_) => rng.nextInt(256),
    );
    final verifier = _base64UrlNoPadding(bytes);
    final challenge = _base64UrlNoPadding(
      sha256.convert(utf8.encode(verifier)).bytes,
    );
    return PkcePair(codeVerifier: verifier, codeChallenge: challenge);
  }

  static String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
