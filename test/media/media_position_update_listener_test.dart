import 'package:flutter_test/flutter_test.dart';
import 'package:openapi/api.dart'
    show OrderableAffectedRecord, PositionUpdatedEventDto;
import 'package:qms_revamped_content_desktop_client/core/app_directory/app_directory_service.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/media/position_update/media_position_update_listener.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/service/media_registry_service.dart';

class _FakeAppDirectoryService extends AppDirectoryService {}

class _CapturingMediaRegistryService extends MediaRegistryService {
  int callCount = 0;
  UpdatePositionRequest? lastRequest;

  _CapturingMediaRegistryService(EventManager eventManager)
    : super(
        appDatabaseManager: AppDatabaseManager(
          appDirectoryService: _FakeAppDirectoryService(),
        ),
        eventManager: eventManager,
      );

  @override
  Future<void> updatePosition(UpdatePositionRequest request) async {
    callCount += 1;
    lastRequest = request;
  }
}

void main() {
  test(
    'ignores PositionUpdatedEventDto with unmatched serviceName or tag',
    () async {
      final eventManager = EventManager()..init();
      final registryService = _CapturingMediaRegistryService(eventManager);

      final listener = MediaPositionUpdateListener(
        serviceName: 'service-a',
        tag: 'main',
        eventManager: eventManager,
        mediaRegistryService: registryService,
      )..init();

      eventManager.publishEvent(
        PositionUpdatedEventDto(
          tableName: 'service-b',
          tag: 'main',
          id: 10,
          newPosition: 1,
        ),
      );
      eventManager.publishEvent(
        PositionUpdatedEventDto(
          tableName: 'service-a',
          tag: 'other',
          id: 10,
          newPosition: 1,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(registryService.callCount, 0);

      await listener.dispose();
    },
  );

  test('maps PositionUpdatedEventDto into UpdatePositionRequest', () async {
    final eventManager = EventManager()..init();
    final registryService = _CapturingMediaRegistryService(eventManager);

    final listener = MediaPositionUpdateListener(
      serviceName: 'service-a',
      tag: 'main',
      eventManager: eventManager,
      mediaRegistryService: registryService,
    )..init();

    eventManager.publishEvent(
      PositionUpdatedEventDto(
        tableName: 'service-a',
        tag: 'main',
        id: 11,
        newPosition: 2,
        affectedRecordRows: [
          OrderableAffectedRecord(id: 20, newPosition: 3),
          OrderableAffectedRecord(id: null, newPosition: 4),
          OrderableAffectedRecord(id: 30, newPosition: 5),
        ],
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(registryService.callCount, 1);
    final request = registryService.lastRequest;
    expect(request, isNotNull);
    expect(request!.currentRecord.id, 11);
    expect(request.currentRecord.position, 2);
    expect(request.affectedRecords.length, 2);
    expect(request.affectedRecords[0].id, 20);
    expect(request.affectedRecords[0].position, 3);
    expect(request.affectedRecords[1].id, 30);
    expect(request.affectedRecords[1].position, 5);

    await listener.dispose();
  });
}
