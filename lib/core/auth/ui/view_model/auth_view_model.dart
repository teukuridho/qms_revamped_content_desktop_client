import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_logger.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/auth_service.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/oidc/model/device_authorization.dart';
import 'package:qms_revamped_content_desktop_client/core/model/process_state.dart';

class AuthViewModel extends ChangeNotifier {
  final OidcAuthService _authService;
  int _qrEpoch = 0;

  ProcessState loginBrowserState = ProcessState(state: ProcessStateEnum.none);
  ProcessState startQrState = ProcessState(state: ProcessStateEnum.none);
  ProcessState pollQrState = ProcessState(state: ProcessStateEnum.none);
  ProcessState logoutState = ProcessState(state: ProcessStateEnum.none);

  DeviceAuthorization? deviceAuthorization;
  bool loggedIn = false;
  int accessTokenExpiresAtEpochMs = 0;

  Timer? _countdownTimer;
  int secondsLeft = 0;

  AuthViewModel({required OidcAuthService authService}) : _authService = authService;

  void _resetQrFlow({String reason = 'reset'}) {
    AuthLogger.info('AuthVM: _resetQrFlow(reason=$reason)');
    _qrEpoch++; // invalidates any in-flight polling loop
    _countdownTimer?.cancel();
    _countdownTimer = null;
    secondsLeft = 0;
    deviceAuthorization = null;
    pollQrState = ProcessState(state: ProcessStateEnum.none);
    startQrState = ProcessState(state: ProcessStateEnum.none);
  }

  Future<void> init({bool autoStartQr = true}) async {
    AuthLogger.info('AuthVM: init(autoStartQr=$autoStartQr)');
    await _refreshStatus();

    if (!autoStartQr) return;
    if (loggedIn) return;
    if (deviceAuthorization != null) return;

    // Only auto-start if Keycloak config is already present in DB to avoid
    // noisy errors on first run.
    final sp = await _authService.getCurrentServerProperties();
    if (sp == null) return;
    if (sp.keycloakBaseUrl.trim().isEmpty ||
        sp.keycloakRealm.trim().isEmpty ||
        sp.keycloakClientId.trim().isEmpty) {
      return;
    }

    unawaited(startQrLogin());
  }

  Future<void> loginWithBrowser() async {
    if (loginBrowserState.state == ProcessStateEnum.loading) return;
    AuthLogger.info('AuthVM: loginWithBrowser');
    // If QR flow is showing, hide it when using browser login.
    _setState(() => _resetQrFlow(reason: 'browser_login'));
    _setState(() {
      loginBrowserState = ProcessState(state: ProcessStateEnum.loading);
    });
    try {
      await _authService.loginWithBrowserPkce();
      _setState(() {
        loginBrowserState = ProcessState(state: ProcessStateEnum.success);
      });
      await _refreshStatus();
      _setState(() => _resetQrFlow(reason: 'browser_login_success'));
    } catch (e) {
      _setState(() {
        loginBrowserState = ProcessState(
          state: ProcessStateEnum.failed,
          errorMessage: e.toString(),
        );
      });
      await _refreshStatus();
    } finally {
      _setState(() {
        loginBrowserState = ProcessState(
          state: ProcessStateEnum.none,
          errorMessage: loginBrowserState.errorMessage,
        );
      });
    }
  }

  Future<void> cancelBrowserLogin() async {
    if (loginBrowserState.state != ProcessStateEnum.loading) return;
    try {
      await _authService.cancelBrowserLogin();
    } finally {
      _setState(() {
        loginBrowserState = ProcessState(state: ProcessStateEnum.none);
      });
    }
  }

  Future<void> startQrLogin() async {
    AuthLogger.info('AuthVM: startQrLogin');
    final epoch = ++_qrEpoch;
    _setState(() {
      startQrState = ProcessState(state: ProcessStateEnum.loading);
      deviceAuthorization = null;
      pollQrState = ProcessState(state: ProcessStateEnum.none);
    });
    try {
      final da = await _authService.startQrLogin();
      _setState(() {
        deviceAuthorization = da;
        startQrState = ProcessState(state: ProcessStateEnum.success);
      });
      _startCountdown(expiresIn: da.expiresIn);

      // Start polling immediately so the operator only needs to scan and approve.
      unawaited(completeQrLogin(epoch: epoch));
    } catch (e) {
      _setState(() {
        startQrState = ProcessState(
          state: ProcessStateEnum.failed,
          errorMessage: e.toString(),
        );
      });
      await _refreshStatus();
    } finally {
      _setState(() {
        startQrState = ProcessState(
          state: ProcessStateEnum.none,
          errorMessage: startQrState.errorMessage,
        );
      });
    }
  }

  Future<void> completeQrLogin({int? epoch}) async {
    if (pollQrState.state == ProcessStateEnum.loading) return;
    final da = deviceAuthorization;
    if (da == null) return;
    final myEpoch = epoch ?? _qrEpoch;
    AuthLogger.info('AuthVM: completeQrLogin(epoch=$myEpoch)');

    _setState(() {
      pollQrState = ProcessState(state: ProcessStateEnum.loading);
    });
    try {
      await _authService.completeQrLoginByPolling(
        da,
        isCancelled: () => myEpoch != _qrEpoch,
      );
      _setState(() {
        pollQrState = ProcessState(state: ProcessStateEnum.success);
      });
      await _refreshStatus();
      _setState(() => _resetQrFlow(reason: 'qr_success'));
    } catch (e) {
      _setState(() {
        pollQrState = ProcessState(
          state: ProcessStateEnum.failed,
          errorMessage: e.toString(),
        );
      });
      await _refreshStatus();
    } finally {
      _setState(() {
        pollQrState = ProcessState(
          state: ProcessStateEnum.none,
          errorMessage: pollQrState.errorMessage,
        );
      });
    }
  }

  void cancelQrPolling() {
    if (pollQrState.state != ProcessStateEnum.loading) return;
    AuthLogger.warn('AuthVM: cancelQrPolling');
    _qrEpoch++; // invalidates the current poll loop
  }

  Future<void> logout() async {
    AuthLogger.info('AuthVM: logout');
    _setState(() {
      logoutState = ProcessState(state: ProcessStateEnum.loading);
    });
    try {
      await _authService.logout();
      _setState(() => _resetQrFlow(reason: 'logout'));
      _setState(() {
        logoutState = ProcessState(state: ProcessStateEnum.success);
      });
      await _refreshStatus();
    } catch (e) {
      _setState(() {
        logoutState = ProcessState(
          state: ProcessStateEnum.failed,
          errorMessage: e.toString(),
        );
      });
      await _refreshStatus();
    } finally {
      _setState(() {
        logoutState = ProcessState(
          state: ProcessStateEnum.none,
          errorMessage: logoutState.errorMessage,
        );
      });
    }
  }

  Future<void> _refreshStatus() async {
    final sp = await _authService.getCurrentServerProperties();
    if (sp == null) {
      _setState(() {
        loggedIn = false;
        accessTokenExpiresAtEpochMs = 0;
      });
      return;
    }

    final nextLoggedIn =
        sp.oidcRefreshToken.isNotEmpty || sp.oidcAccessToken.isNotEmpty;
    _setState(() {
      loggedIn = nextLoggedIn;
      accessTokenExpiresAtEpochMs = sp.oidcExpiresAtEpochMs;
    });
  }

  void _startCountdown({required int expiresIn}) {
    _countdownTimer?.cancel();
    secondsLeft = expiresIn;
    if (expiresIn <= 0) return;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft -= 1;
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        t.cancel();
      }
      notifyListeners();
    });
  }

  void _setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  @override
  void dispose() {
    // Best-effort cleanup to avoid leaving a loopback server running.
    unawaited(_authService.cancelBrowserLogin());
    _countdownTimer?.cancel();
    super.dispose();
  }
}
