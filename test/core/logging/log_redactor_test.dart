import 'package:flutter_test/flutter_test.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/log_redactor.dart';

void main() {
  group('LogRedactor', () {
    test('redacts Bearer tokens', () {
      final input = 'Authorization: Bearer abc.def.ghi';
      final out = LogRedactor.redact(input);
      expect(out, contains('Bearer <redacted>'));
      expect(out, isNot(contains('abc.def.ghi')));
    });

    test('redacts jwt-like strings', () {
      final input =
          'token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      final out = LogRedactor.redact(input);
      expect(out, isNot(contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')));
    });

    test('redacts token key/value patterns', () {
      final input =
          'access_token=secret refresh_token=moresecret password=hunter2';
      final out = LogRedactor.redact(input);
      expect(out, contains('access_token=<redacted>'));
      expect(out, contains('refresh_token=<redacted>'));
      expect(out, contains('password=<redacted>'));
      expect(out, isNot(contains('hunter2')));
    });
  });
}
