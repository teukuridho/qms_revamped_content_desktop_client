import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:qms_revamped_content_desktop_client/core/auth/auth_logger.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/keycloak_oidc_client.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/loopback_server.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/device_authorization.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/oidc_config.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/token_set.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/oidc_exception.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/pkce.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/update_service_by_name_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OidcAuthService {
  static const String defaultScope = 'openid offline_access';

  final String _serviceName;
  final ServerPropertiesRegistryService _serverPropertiesRegistryService;
  final EventManager? _eventManager;
  final KeycloakOidcClient _oidcClient;
  LoopbackServer? _activeLoopback;

  OidcAuthService({
    required String serviceName,
    required ServerPropertiesRegistryService serverPropertiesRegistryService,
    EventManager? eventManager,
    KeycloakOidcClient? oidcClient,
  }) : _serviceName = serviceName,
       _serverPropertiesRegistryService = serverPropertiesRegistryService,
       _eventManager = eventManager,
       _oidcClient = oidcClient ?? KeycloakOidcClient();

  Future<DeviceAuthorization> startQrLogin({String scope = defaultScope}) async {
    AuthLogger.info('Auth[$_serviceName]: startQrLogin');
    final config = await _loadConfigOrThrow();
    final da = await _oidcClient.startDeviceAuthorization(config: config, scope: scope);
    AuthLogger.info('Auth[$_serviceName]: device authorization started (expiresIn=${da.expiresIn}s interval=${da.interval}s)');
    return da;
  }

  Future<void> completeQrLoginByPolling(
    DeviceAuthorization da, {
    String scope = defaultScope,
    bool Function()? isCancelled,
  }) async {
    AuthLogger.info('Auth[$_serviceName]: completeQrLoginByPolling');
    final config = await _loadConfigOrThrow();
    var intervalSeconds = da.interval <= 0 ? 5 : da.interval;
    final expiresAt = DateTime.now().add(Duration(seconds: da.expiresIn));

    while (DateTime.now().isBefore(expiresAt)) {
      if (isCancelled?.call() == true) {
        AuthLogger.warn('Auth[$_serviceName]: device polling canceled');
        throw const OidcProtocolException('QR login canceled');
      }
      try {
        final tokenSet = await _oidcClient.pollDeviceTokens(
          config: config,
          deviceCode: da.deviceCode,
        );
        final sp = await _persistTokenSet(tokenSet);
        _publishLoggedInEvent(
          method: 'device_qr',
          tokenSet: tokenSet,
          serverProperty: sp,
        );
        AuthLogger.info('Auth[$_serviceName]: device polling success; tokens saved');
        return;
      } on OidcOAuthException catch (e) {
        AuthLogger.info('Auth[$_serviceName]: device polling oauth error=${e.error}');
        switch (e.error) {
          case 'authorization_pending':
            await Future<void>.delayed(Duration(seconds: intervalSeconds));
            continue;
          case 'slow_down':
            intervalSeconds += 5;
            await Future<void>.delayed(Duration(seconds: intervalSeconds));
            continue;
          case 'expired_token':
          case 'access_denied':
            rethrow;
          default:
            rethrow;
        }
      }
    }

    throw const OidcOAuthException('expired_token');
  }

  Future<void> loginWithBrowserPkce({String scope = defaultScope}) async {
    AuthLogger.info('Auth[$_serviceName]: loginWithBrowserPkce');
    final config = await _loadConfigOrThrow();

    // Avoid multiple overlapping browser logins. If a previous attempt is still
    // active, cancel it first so retries always work.
    final previous = _activeLoopback;
    if (previous != null) {
      await previous.cancel('Superseded by a new login attempt');
    }

    final loopback = LoopbackServer();
    _activeLoopback = loopback;
    await loopback.start();

    final pkce = PkcePair.generate();
    final state = _randomBase64Url(32);
    final redirectUri = loopback.redirectUri;
    // Build from the actual Keycloak auth endpoint (but with query params).
    final keycloakAuth = Uri.parse(
      '${config.baseUrl}/realms/${Uri.encodeComponent(config.realm)}/protocol/openid-connect/auth',
    );
    final url = keycloakAuth.replace(
      queryParameters: {
        'client_id': config.clientId,
        'response_type': 'code',
        'scope': scope,
        'redirect_uri': redirectUri.toString(),
        'code_challenge': pkce.codeChallenge,
        'code_challenge_method': 'S256',
        'state': state,
      },
    );

    // platformDefault tends to behave better across desktop targets.
    if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
      await loopback.close();
      throw const OidcProtocolException('Unable to open system browser');
    }

    try {
      final callbackUrl = await loopback.waitForRedirect();
      final qp = callbackUrl.queryParameters;
      final returnedState = qp['state'];
      if (returnedState != state) {
        throw const OidcProtocolException('Invalid state returned in callback');
      }

      final code = qp['code'];
      if (code == null || code.isEmpty) {
        final error = qp['error'];
        final desc = qp['error_description'];
        if (error != null && error.isNotEmpty) {
          throw OidcOAuthException(error, errorDescription: desc);
        }
        throw const OidcProtocolException('Missing authorization code');
      }

      final tokenSet = await _oidcClient.exchangeCodeForTokens(
        config: config,
        code: code,
        redirectUri: redirectUri,
        codeVerifier: pkce.codeVerifier,
      );
      final sp = await _persistTokenSet(tokenSet);
      _publishLoggedInEvent(
        method: 'browser_pkce',
        tokenSet: tokenSet,
        serverProperty: sp,
      );
      AuthLogger.info('Auth[$_serviceName]: browser login success; tokens saved');
    } on TimeoutException {
      throw const OidcProtocolException(
        'Browser login timed out. Please complete login in the browser and try again.',
      );
    } catch (e, st) {
      AuthLogger.error('Auth[$_serviceName]: browser login failed', error: e, stackTrace: st);
      rethrow;
    } finally {
      if (identical(_activeLoopback, loopback)) {
        _activeLoopback = null;
      }
      await loopback.close();
    }
  }

  Future<void> cancelBrowserLogin() async {
    final lb = _activeLoopback;
    _activeLoopback = null;
    if (lb != null) {
      await lb.cancel();
    }
  }

  Future<String?> getValidAccessToken({Duration refreshSkew = const Duration(seconds: 30)}) async {
    AuthLogger.info('Auth[$_serviceName]: getValidAccessToken');
    final sp = await _loadServerPropertiesOrNull();
    if (sp == null) return null;

    final access = sp.oidcAccessToken;
    final refresh = sp.oidcRefreshToken;
    if (access.isEmpty) return null;

    final expiresAtMs = sp.oidcExpiresAtEpochMs;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final shouldRefresh = expiresAtMs > 0 && nowMs >= (expiresAtMs - refreshSkew.inMilliseconds);
    if (!shouldRefresh) return access;

    if (refresh.isEmpty) return null;

    try {
      final config = await _loadConfigOrThrow();
      final tokenSet = await _oidcClient.refreshTokens(config: config, refreshToken: refresh);
      await _persistTokenSet(tokenSet);
      AuthLogger.info('Auth[$_serviceName]: refresh success; tokens saved');
      return tokenSet.accessToken;
    } on OidcOAuthException catch (e) {
      if (e.error == 'invalid_grant') {
        await logout();
        return null;
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    AuthLogger.info('Auth[$_serviceName]: logout (clear tokens)');
    await _serverPropertiesRegistryService.updateByServiceName(
      UpdateServiceByNameRequest(
        serviceName: _serviceName,
        oidcAccessToken: '',
        oidcRefreshToken: '',
        oidcIdToken: '',
        oidcExpiresAtEpochMs: 0,
        oidcScope: '',
        oidcTokenType: '',
      ),
    );
  }

  Future<ServerProperty?> getCurrentServerProperties() {
    return _loadServerPropertiesOrNull();
  }

  Future<ServerProperty?> _persistTokenSet(OidcTokenSet tokenSet) async {
    return _serverPropertiesRegistryService.updateByServiceName(
      UpdateServiceByNameRequest(
        serviceName: _serviceName,
        oidcAccessToken: tokenSet.accessToken,
        oidcRefreshToken: tokenSet.refreshToken,
        oidcIdToken: tokenSet.idToken,
        oidcExpiresAtEpochMs: tokenSet.expiresAtEpochMs,
        oidcScope: tokenSet.scope,
        oidcTokenType: tokenSet.tokenType,
      ),
    );
  }

  void _publishLoggedInEvent({
    required String method,
    required OidcTokenSet tokenSet,
    required ServerProperty? serverProperty,
  }) {
    final em = _eventManager;
    final sp = serverProperty;
    if (em == null || sp == null) return;

    // Don't include raw tokens in events.
    em.publishEvent(
      AuthLoggedInEvent(
        serviceName: _serviceName,
        method: method,
        loggedInAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        keycloakBaseUrl: sp.keycloakBaseUrl,
        keycloakRealm: sp.keycloakRealm,
        keycloakClientId: sp.keycloakClientId,
        scope: tokenSet.scope,
        tokenType: tokenSet.tokenType,
        accessTokenExpiresAtEpochMs: tokenSet.expiresAtEpochMs,
        hasRefreshToken: tokenSet.refreshToken.isNotEmpty,
      ),
    );
  }

  Future<OidcConfig> _loadConfigOrThrow() async {
    final sp = await _loadServerPropertiesOrNull();
    if (sp == null) {
      throw const OidcProtocolException(
        'Missing server properties for this serviceName. Save settings first.',
      );
    }

    final baseUrl = sp.keycloakBaseUrl.trim();
    final realm = sp.keycloakRealm.trim();
    final clientId = sp.keycloakClientId.trim();

    if (baseUrl.isEmpty || realm.isEmpty || clientId.isEmpty) {
      throw const OidcProtocolException(
        'Keycloak settings are incomplete. Please set base URL, realm, and client id.',
      );
    }

    // Normalization happens in OidcEndpoints too, but we keep baseUrl clean here
    // for URL building in the browser flow.
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.replaceAll(RegExp(r'/+$'), '')
        : baseUrl;

    return OidcConfig(baseUrl: normalized, realm: realm, clientId: clientId);
  }

  Future<ServerProperty?> _loadServerPropertiesOrNull() async {
    return _serverPropertiesRegistryService.getOneByServiceName(serviceName: _serviceName);
  }

  static String _randomBase64Url(int byteLength) {
    final rng = Random.secure();
    final bytes = List<int>.generate(byteLength, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
