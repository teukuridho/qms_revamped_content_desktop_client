import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:openapi/api.dart';
import 'package:qms_revamped_content_desktop_client/core/auth/event/auth_logged_in_event.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/create_server_properties_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/update_service_by_name_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/service/server_properties_registry_service.dart';
import 'package:qms_revamped_content_desktop_client/media/downloader/media_downloader_base.dart';
import 'package:qms_revamped_content_desktop_client/media/player/controller/media_reload_signal.dart';
import 'package:qms_revamped_content_desktop_client/media/storage/service/media_deleter_base.dart';
import 'package:qms_revamped_content_desktop_client/media/synchronizer/media_synchronizer.dart';
import 'package:qms_revamped_content_desktop_client/sse_client/sse_client.dart';

class FakeServerPropertiesRegistryService
    implements ServerPropertiesRegistryService {
  final ServerProperty? serverProperty;

  FakeServerPropertiesRegistryService(this.serverProperty);

  @override
  Future<ServerProperty?> getOneByServiceName({
    required String serviceName,
  }) async {
    return serverProperty;
  }

  @override
  Future<ServerProperty> create(CreateServerPropertiesRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<ServerProperty?> updateByServiceName(
    UpdateServiceByNameRequest request,
  ) {
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
    Stream<T> out = _ctrl(
      fieldKey,
    ).stream.cast<String>().map((e) => parser.parse(e));
    if (distinct) out = out.distinct();
    return out;
  }
}

class FakeDownloader implements MediaDownloaderBase {
  final List<int> downloadedRemoteIds = [];

  @override
  Future<void> downloadOne(MediaDto dto) async {
    downloadedRemoteIds.add(dto.id);
  }
}

class FakeDeleter implements MediaDeleterBase {
  final List<int> deletedRemoteIds = [];

  @override
  Future<void> deleteLocalByRemoteId(int remoteId) async {
    deletedRemoteIds.add(remoteId);
  }
}

class FakeReloadSignal implements MediaReloadSignal {
  int calls = 0;

  @override
  void markReloadNeeded() {
    calls += 1;
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

MediaDto _mediaDto({required int id, required String tag}) {
  return MediaDto(
    id: id,
    tenantId: 't',
    objectKey: 'k',
    contentType: MediaDtoContentTypeEnum.IMAGE,
    status: MediaDtoStatusEnum.READY,
    position: 1,
    fileName: 'a.png',
    mimeType: 'image/png',
    tag: tag,
  );
}

void main() {
  late Duration oldDelay;

  setUp(() {
    oldDelay = MediaSynchronizer.retryDelay;
    MediaSynchronizer.retryDelay = const Duration(milliseconds: 20);
  });

  tearDown(() {
    MediaSynchronizer.retryDelay = oldDelay;
  });

  test(
    'does not subscribe when AuthLoggedInEvent serviceName does not match',
    () async {
      final em = EventManager()..init();
      var factoryCalls = 0;

      final sync = MediaSynchronizer(
        serviceName: 'svcA',
        tag: 'main',
        eventManager: em,
        serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
          _serverProperty(
            serviceName: 'svcA',
            serverAddress: 'https://example.com',
            accessToken: 'tok',
          ),
        ),
        downloader: FakeDownloader(),
        deleter: FakeDeleter(),
        playerController: FakeReloadSignal(),
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

      await sync.dispose();
    },
  );

  test(
    'subscribes and handles media-uploaded + media-deleted events',
    () async {
      final em = EventManager()..init();
      final serviceName = 'svcA';
      final tag = 'main';

      SseClientOptions? capturedOptions;
      late FakeSseClient fakeClient;

      final downloader = FakeDownloader();
      final deleter = FakeDeleter();
      final reload = FakeReloadSignal();

      final sync = MediaSynchronizer(
        serviceName: serviceName,
        tag: tag,
        eventManager: em,
        serverPropertiesRegistryService: FakeServerPropertiesRegistryService(
          _serverProperty(
            serviceName: serviceName,
            serverAddress: 'https://example.com/api',
            accessToken: 'token123',
          ),
        ),
        downloader: downloader,
        deleter: deleter,
        playerController: reload,
        sseClientFactory: (options) {
          capturedOptions = options;
          fakeClient = FakeSseClient(options);
          return fakeClient;
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

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.url.path, '/api/media-subscribe');
      expect(capturedOptions!.url.queryParameters['tag'], tag);
      expect(capturedOptions!.headers['Authorization'], 'Bearer token123');

      fakeClient.add(
        MediaSynchronizer.uploadedFieldKey,
        jsonEncode({'media': _mediaDto(id: 10, tag: tag).toJson()}),
      );

      fakeClient.add(MediaSynchronizer.deletedFieldKey, jsonEncode({'id': 99}));

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(downloader.downloadedRemoteIds, contains(10));
      expect(deleter.deletedRemoteIds, contains(99));
      expect(reload.calls, greaterThanOrEqualTo(2));

      await sync.dispose();
    },
  );
}
