import 'dart:async';
import 'dart:io';

import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';

class LoopbackCanceledException implements Exception {
  final String message;
  const LoopbackCanceledException([this.message = 'Loopback login canceled']);

  @override
  String toString() => 'LoopbackCanceledException($message)';
}

class LoopbackServer {
  static final AppLog _log = AppLog('oidc.loopback');

  HttpServer? _server;
  final Completer<Uri> _redirectCompleter = Completer<Uri>();

  Future<void> start() async {
    if (_server != null) return;
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _log.i('Started loopback server on 127.0.0.1:${_server!.port}');

    _server!.listen((req) async {
      // Build an absolute URL so callers can inspect it uniformly.
      final url = Uri(
        scheme: 'http',
        host: InternetAddress.loopbackIPv4.address,
        port: _server!.port,
        path: req.uri.path,
        query: req.uri.query,
      );

      final qp = req.uri.queryParameters;
      // We treat any request with OAuth query parameters as a callback. This
      // avoids relying on a fixed callback path, which improves compatibility
      // with IdP redirect URI validation rules.
      final isCallback =
          qp.containsKey('code') ||
          qp.containsKey('error') ||
          qp.containsKey('state');
      if (isCallback && !_redirectCompleter.isCompleted) {
        _log.i('Received OIDC callback');
        _redirectCompleter.complete(url);
      }

      req.response.statusCode = 200;
      req.response.headers.contentType = ContentType.html;
      req.response.write(
        '<!doctype html><html><body><h3>Login completed.</h3>'
        '<p>You may close this window.</p></body></html>',
      );
      await req.response.close();

      // Shutdown only after we receive the OIDC callback.
      if (isCallback) {
        await close();
      }
    });
  }

  Uri get redirectUri {
    final server = _server;
    if (server == null) {
      throw StateError('LoopbackServer not started');
    }
    // No fixed path: Keycloak has special handling for `http://127.0.0.1` which
    // allows any port for native apps (RFC 8252 loopback redirect).
    return Uri.parse('http://127.0.0.1:${server.port}/');
  }

  Future<Uri> waitForRedirect({Duration timeout = const Duration(minutes: 5)}) {
    return _redirectCompleter.future.timeout(timeout);
  }

  Future<void> cancel([String message = 'Canceled by user']) async {
    _log.w('Cancel: $message');
    if (!_redirectCompleter.isCompleted) {
      _redirectCompleter.completeError(LoopbackCanceledException(message));
    }
    await close();
  }

  Future<void> close() async {
    final server = _server;
    _server = null;
    if (server != null) {
      _log.i('Closing loopback server');
      await server.close(force: true);
    }
  }
}
