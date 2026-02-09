import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:qms_revamped_content_desktop_client/core/auth/auth_logger.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/device_authorization.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/oidc_config.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/token_set.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/oidc_endpoints.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/oidc_exception.dart';

class KeycloakOidcClient {
  final http.Client _http;
  final Duration requestTimeout;

  KeycloakOidcClient({
    http.Client? httpClient,
    this.requestTimeout = const Duration(seconds: 30),
  }) : _http = httpClient ?? http.Client();

  Future<OidcTokenSet> exchangeCodeForTokens({
    required OidcConfig config,
    required String code,
    required Uri redirectUri,
    required String codeVerifier,
  }) async {
    final endpoints = OidcEndpoints.fromConfig(config);
    AuthLogger.info('OIDC: Exchanging auth code for tokens');
    final res = await _postForm(
      endpoints.tokenEndpoint,
      body: {
        'grant_type': 'authorization_code',
        'client_id': config.clientId,
        'code': code,
        'redirect_uri': redirectUri.toString(),
        'code_verifier': codeVerifier,
      },
    );
    return _parseTokenResponse(res);
  }

  Future<OidcTokenSet> refreshTokens({
    required OidcConfig config,
    required String refreshToken,
  }) async {
    final endpoints = OidcEndpoints.fromConfig(config);
    AuthLogger.info('OIDC: Refreshing tokens');
    final res = await _postForm(
      endpoints.tokenEndpoint,
      body: {
        'grant_type': 'refresh_token',
        'client_id': config.clientId,
        'refresh_token': refreshToken,
      },
    );
    return _parseTokenResponse(res);
  }

  Future<DeviceAuthorization> startDeviceAuthorization({
    required OidcConfig config,
    required String scope,
  }) async {
    final endpoints = OidcEndpoints.fromConfig(config);
    AuthLogger.info('OIDC: Starting device authorization');
    final res = await _postForm(
      endpoints.deviceAuthorizationEndpoint,
      body: {
        'client_id': config.clientId,
        'scope': scope,
      },
    );

    final json = _parseJsonResponse(res);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _parseOAuthError(json);
    }

    return DeviceAuthorization(
      deviceCode: (json['device_code'] as String?) ?? '',
      userCode: (json['user_code'] as String?) ?? '',
      verificationUri: (json['verification_uri'] as String?) ?? '',
      verificationUriComplete: (json['verification_uri_complete'] as String?) ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      interval: (json['interval'] as num?)?.toInt() ?? 5,
    );
  }

  Future<OidcTokenSet> pollDeviceTokens({
    required OidcConfig config,
    required String deviceCode,
  }) async {
    final endpoints = OidcEndpoints.fromConfig(config);
    final res = await _postForm(
      endpoints.tokenEndpoint,
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        'device_code': deviceCode,
        'client_id': config.clientId,
      },
    );
    return _parseTokenResponse(res);
  }

  Future<http.Response> _postForm(Uri url, {required Map<String, String> body}) async {
    try {
      final res = await _http
          .post(
            url,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: body,
          )
          .timeout(requestTimeout);
      AuthLogger.info('OIDC: POST ${url.path} -> ${res.statusCode}');
      return res;
    } on TimeoutException catch (e, st) {
      AuthLogger.error('OIDC: Request timed out: $url', error: e, stackTrace: st);
      throw const OidcProtocolException('Network timeout talking to Keycloak');
    } catch (e, st) {
      AuthLogger.error('OIDC: Network error: $url', error: e, stackTrace: st);
      throw OidcProtocolException('Network error talking to Keycloak: $e');
    }
  }

  OidcTokenSet _parseTokenResponse(http.Response res) {
    final json = _parseJsonResponse(res);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw _parseOAuthError(json);
    }

    final accessToken = (json['access_token'] as String?) ?? '';
    final refreshToken = (json['refresh_token'] as String?) ?? '';
    final idToken = (json['id_token'] as String?) ?? '';
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 0;
    final tokenType = (json['token_type'] as String?) ?? '';
    final scope = (json['scope'] as String?) ?? '';

    return OidcTokenSet(
      accessToken: accessToken,
      refreshToken: refreshToken,
      idToken: idToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      scope: scope,
      tokenType: tokenType,
    );
  }

  Map<String, dynamic> _parseJsonResponse(http.Response res) {
    try {
      final body = res.body;
      if (body.isEmpty) return const {};
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const OidcProtocolException('Expected JSON object response');
    } catch (e) {
      throw OidcProtocolException('Invalid JSON response: $e');
    }
  }

  OidcOAuthException _parseOAuthError(Map<String, dynamic> json) {
    final error = (json['error'] as String?) ?? 'unknown_error';
    final desc = (json['error_description'] as String?) ?? (json['errorDescription'] as String?);
    return OidcOAuthException(error, errorDescription: desc);
  }

  void close() => _http.close();
}
