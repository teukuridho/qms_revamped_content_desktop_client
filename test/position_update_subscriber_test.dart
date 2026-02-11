import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:openapi/api.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/event/position_update_sse_id_mismatch_event.dart';
import 'package:qms_revamped_content_desktop_client/core/position_update/subscriber/position_update_subscriber.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/create_server_properties_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/update_service_by_name_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

class FakeServerPropertiesRegistryService implements ServerPropertiesRegistryService {
  final ServerProperty? serverProperty;

  FakeServerPropertiesRegistryService(this.serverProperty);

  @override
  Future<ServerProperty?> getOneByServiceName({required String serviceName}) async {
    return serverProperty;
  }

  @override
  Future<ServerProperty> create(CreateServerPropertiesRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<ServerProperty?> updateByServiceName(UpdateServiceByNameRequest request) {
    throw UnimplementedError();
  }
}

class FakeSseClient implements SseClientBase {
  @override
  final SseClientOptions options;

  bool _closed = false;
  bool _started = false;

  final Map<String, StreamController<dynamic>> _streams = {};

  FakeSseClient(this.options);

  StreamController<dynamic> _ctrl(String key) =>
      _streams.putIfAbsent(key, () => StreamController<dynamic>.broadcast());

  void add(String key, dynamic value) => _ctrl(key).add(value);
  void addError(String key, Object error) => _ctrl(key).addError(error);
  Future<void> end(String key) async => _ctrl(key).close();

  @override
  Stream<SseFrame> get frames => const Stream<SseFrame>.empty();

  @override
  bool get isRunning => _started && !_closed;

  @override
  Future<void> start() async {
    _started = true;
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    for (final c in _streams.values) {
      await c.close();
    }
  }

  @override
  Stream<T> listen<T>(
    String fieldKey, {
    required SseValueParser<T> parser,
    bool distinct = false,
  }) {
    Stream<T> out = _ctrl(fieldKey).stream.cast<T>();
    if (distinct) out = out.distinct();
    return out;
  }
}

ServerProperty _serverProperty({
  required String serviceName,
  required String serverAddress,
  required String accessToken,
}) {
  return ServerProperty(
    id: 1,
    serviceName: serviceName,
    serverAddress: serverAddress,
    keycloakBaseUrl: '',
    keycloakRealm: '',
    keycloakClientId: '',
    oidcAccessToken: accessToken,
    oidcRefreshToken: '',
    oidcIdToken: '',
    oidcExpiresAtEpochMs: 0,
    oidcScope: '',
    oidcTokenType: '',
  );
}

void main() {
  late Duration oldDelay;

  setUp(() {
    oldDelay = PositionUpdateSubscriber.retryDelay;
    PositionUpdateSubscriber.retryDelay = const Duration(milliseconds: 20);
  });

  tearDown(() {
    PositionUpdateSubscriber.retryDelay = oldDelay;
  });

  test('does not subscribe when AuthLoggedInEvent serviceName does not match', () async {
    final em = EventManager()..init();
    var factoryCalls = 0;

    final subscriber = PositionUpdateSubscriber(
      serviceName: 'svcA',
      tag: 't1',
      sseIncrementalMismatchCallback: (_) {},
      eventManager: em,
      serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
        _serverProperty(
          serviceName: 'svcA',
          serverAddress: 'https://example.com',
          accessToken: 'tok',
        ),
      ),
      sseClientFactory: (options) {
        factoryCalls += 1;
        return FakeSseClient(options);
      },
    )..init();

    em.publishEvent(
      AuthLoggedInEvent(
        serviceName: 'svcB',
        method: 'browser_pkce',
        loggedInAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        keycloakBaseUrl: '',
        keycloakRealm: '',
        keycloakClientId: '',
        scope: '',
        tokenType: '',
        accessTokenExpiresAtEpochMs: 0,
        hasRefreshToken: false,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(factoryCalls, 0);

    await subscriber.dispose();
  });

  test('subscribes and publishes PositionUpdatedEventDto when payload matches tag+tableName', () async {
    final em = EventManager()..init();
    final serviceName = 'svcA';
    final tag = 't1';

    SseClientOptions? capturedOptions;
    late FakeSseClient fakeClient;

    final subscriber = PositionUpdateSubscriber(
      serviceName: serviceName,
      tag: tag,
      sseIncrementalMismatchCallback: (_) {},
      eventManager: em,
      serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
        _serverProperty(
          serviceName: serviceName,
          serverAddress: 'https://example.com/api',
          accessToken: 'token123',
        ),
      ),
      sseClientFactory: (options) {
        capturedOptions = options;
        fakeClient = FakeSseClient(options);
        return fakeClient;
      },
    )..init();

    final got = Completer<PositionUpdatedEventDto>();
    final sub = em.listen<PositionUpdatedEventDto>().listen((dto) {
      if (!got.isCompleted) got.complete(dto);
    });

    em.publishEvent(
      AuthLoggedInEvent(
        serviceName: serviceName,
        method: 'browser_pkce',
        loggedInAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        keycloakBaseUrl: '',
        keycloakRealm: '',
        keycloakClientId: '',
        scope: '',
        tokenType: '',
        accessTokenExpiresAtEpochMs: 0,
        hasRefreshToken: false,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(capturedOptions, isNotNull);
    expect(capturedOptions!.url.path, '/api/position-updated-subscribe');
    expect(capturedOptions!.url.queryParameters['tableName'], serviceName);
    expect(capturedOptions!.url.queryParameters['tag'], tag);
    expect(capturedOptions!.headers['Authorization'], 'Bearer token123');
    expect(capturedOptions!.enableSseIncrementalIdMismatch, isTrue);
    expect(capturedOptions!.shouldRefreshWhenIdMismatch, isTrue);
    expect(capturedOptions!.sseIncrementalMismatchCallback, isNotNull);

    fakeClient.add(PositionUpdateSubscriber.sseFieldKey, {
      'tableName': serviceName,
      'tag': tag,
      'id': 10,
      'newPosition': 2,
      'affectedRecordRows': <dynamic>[],
    });

    final dto = await got.future.timeout(const Duration(seconds: 1));
    expect(dto.tableName, serviceName);
    expect(dto.tag, tag);
    expect(dto.id, 10);
    expect(dto.newPosition, 2);

    await sub.cancel();
    await subscriber.dispose();
  });

  test('ignores PositionUpdatedEventDto when payload does not match tag+tableName', () async {
    final em = EventManager()..init();
    final serviceName = 'svcA';
    final tag = 't1';

    late FakeSseClient fakeClient;

    final subscriber = PositionUpdateSubscriber(
      serviceName: serviceName,
      tag: tag,
      sseIncrementalMismatchCallback: (_) {},
      eventManager: em,
      serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
        _serverProperty(
          serviceName: serviceName,
          serverAddress: 'https://example.com',
          accessToken: 'token123',
        ),
      ),
      sseClientFactory: (options) {
        fakeClient = FakeSseClient(options);
        return fakeClient;
      },
    )..init();

    var eventCount = 0;
    final sub = em.listen<PositionUpdatedEventDto>().listen((_) {
      eventCount += 1;
    });

    em.publishEvent(
      AuthLoggedInEvent(
        serviceName: serviceName,
        method: 'browser_pkce',
        loggedInAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        keycloakBaseUrl: '',
        keycloakRealm: '',
        keycloakClientId: '',
        scope: '',
        tokenType: '',
        accessTokenExpiresAtEpochMs: 0,
        hasRefreshToken: false,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 30));

    // Wrong tag
    fakeClient.add(PositionUpdateSubscriber.sseFieldKey, {
      'tableName': serviceName,
      'tag': 'other',
      'id': 1,
      'newPosition': 1,
      'affectedRecordRows': <dynamic>[],
    });
    // Wrong tableName
    fakeClient.add(PositionUpdateSubscriber.sseFieldKey, {
      'tableName': 'other',
      'tag': tag,
      'id': 2,
      'newPosition': 2,
      'affectedRecordRows': <dynamic>[],
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(eventCount, 0);

    await sub.cancel();
    await subscriber.dispose();
  });

  test('retries after exception during subscribe setup', () async {
    final em = EventManager()..init();
    final serviceName = 'svcA';
    final tag = 't1';

    var factoryCalls = 0;

    final subscriber = PositionUpdateSubscriber(
      serviceName: serviceName,
      tag: tag,
      sseIncrementalMismatchCallback: (_) {},
      eventManager: em,
      serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
        _serverProperty(
          serviceName: serviceName,
          serverAddress: 'https://example.com',
          accessToken: 'token123',
        ),
      ),
      sseClientFactory: (options) {
        factoryCalls += 1;
        if (factoryCalls == 1) {
          throw Exception('boom');
        }
        return FakeSseClient(options);
      },
    )..init();

    em.publishEvent(
      AuthLoggedInEvent(
        serviceName: serviceName,
        method: 'browser_pkce',
        loggedInAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        keycloakBaseUrl: '',
        keycloakRealm: '',
        keycloakClientId: '',
        scope: '',
        tokenType: '',
        accessTokenExpiresAtEpochMs: 0,
        hasRefreshToken: false,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(factoryCalls, greaterThanOrEqualTo(2));

    await subscriber.dispose();
  });

  test('publishes PositionUpdateSseIdMismatchEvent and invokes callback on mismatch', () async {
    final em = EventManager()..init();
    final serviceName = 'svcA';
    final tag = 't1';

    SseClientOptions? capturedOptions;
    var callbackCalled = 0;

    final subscriber = PositionUpdateSubscriber(
      serviceName: serviceName,
      tag: tag,
      sseIncrementalMismatchCallback: (_) {
        callbackCalled += 1;
      },
      eventManager: em,
      serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
        _serverProperty(
          serviceName: serviceName,
          serverAddress: 'https://example.com',
          accessToken: 'token123',
        ),
      ),
      sseClientFactory: (options) {
        capturedOptions = options;
        return FakeSseClient(options);
      },
    )..init();

    final got = Completer<PositionUpdateSseIdMismatchEvent>();
    final sub = em.listen<PositionUpdateSseIdMismatchEvent>().listen((event) {
      if (!got.isCompleted) got.complete(event);
    });

    em.publishEvent(
      AuthLoggedInEvent(
        serviceName: serviceName,
        method: 'browser_pkce',
        loggedInAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        keycloakBaseUrl: '',
        keycloakRealm: '',
        keycloakClientId: '',
        scope: '',
        tokenType: '',
        accessTokenExpiresAtEpochMs: 0,
        hasRefreshToken: false,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(capturedOptions, isNotNull);
    expect(capturedOptions!.sseIncrementalMismatchCallback, isNotNull);

    final mismatch = SseIncrementalIdMismatch(
      expectedId: 5,
      actualIdRaw: '9',
      actualIdParsed: 9,
      reason: SseIncrementalIdMismatchReason.unexpectedId,
      frame: SseFrame.fromFields(const {'id': ['9']}),
    );

    capturedOptions!.sseIncrementalMismatchCallback!(mismatch);

    final published = await got.future.timeout(const Duration(seconds: 1));
    expect(published.serviceName, serviceName);
    expect(published.tag, tag);
    expect(published.mismatch, same(mismatch));
    expect(published.occurredAtEpochMs, greaterThan(0));
    expect(callbackCalled, 1);

    await sub.cancel();
    await subscriber.dispose();
  });
}
