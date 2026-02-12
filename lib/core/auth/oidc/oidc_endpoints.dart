import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/oidc_config.dart';

class OidcEndpoints {
  final Uri authorizationEndpoint;
  final Uri tokenEndpoint;
  final Uri deviceAuthorizationEndpoint;

  OidcEndpoints({
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.deviceAuthorizationEndpoint,
  });

  factory OidcEndpoints.fromConfig(OidcConfig config) {
    final base = normalizeBaseUrl(config.baseUrl);
    final realm = Uri.encodeComponent(config.realm);

    final auth = Uri.parse('$base/realms/$realm/protocol/openid-connect/auth');
    final token = Uri.parse(
      '$base/realms/$realm/protocol/openid-connect/token',
    );
    final device = Uri.parse(
      '$base/realms/$realm/protocol/openid-connect/auth/device',
    );

    return OidcEndpoints(
      authorizationEndpoint: auth,
      tokenEndpoint: token,
      deviceAuthorizationEndpoint: device,
    );
  }

  static String normalizeBaseUrl(String baseUrl) {
    // Keep it simple: trim whitespace and remove trailing slashes.
    var out = baseUrl.trim();
    while (out.endsWith('/')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }
}
