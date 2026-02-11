import 'dart:async';

import 'package:openapi/api.dart' show PositionUpdatedEventDto;
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/service/media_registry_service.dart';

class MediaPositionUpdateListener {
  static final AppLog _log = AppLog('media_pos_listener');

  final String serviceName;
  final String tag;
  final EventManager _eventManager;
  final MediaRegistryService _mediaRegistryService;

  StreamSubscription<PositionUpdatedEventDto>? _sub;

  MediaPositionUpdateListener({
    required this.serviceName,
    required this.tag,
    required EventManager eventManager,
    required MediaRegistryService mediaRegistryService,
  }) : _eventManager = eventManager,
       _mediaRegistryService = mediaRegistryService;

  void init() {
    _sub ??= _eventManager.listen<PositionUpdatedEventDto>().listen((dto) {
      final dtoServiceName = dto.tableName;
      final dtoTag = dto.tag;
      if (dtoServiceName != serviceName || dtoTag != tag) return;
      unawaited(_updatePosition(dto));
    });
  }

  Future<void> _updatePosition(PositionUpdatedEventDto dto) async {
    final remoteId = dto.id;
    final newPosition = dto.newPosition;
    if (remoteId == null || newPosition == null) {
      _log.w(
        'Ignoring invalid PositionUpdatedEventDto (missing id/newPosition): $dto',
      );
      return;
    }

    final rows = await _mediaRegistryService.getAllByTagOrdered(tag: tag);
    final localIdByRemoteId = <int, int>{};
    for (final row in rows) {
      localIdByRemoteId[row.remoteId] = row.id;
    }

    final localId = localIdByRemoteId[remoteId];
    if (localId == null) {
      _log.w(
        'Skipping position update: current remoteId=$remoteId not found locally (tag=$tag)',
      );
      return;
    }

    final affectedRecords = <RecordWithPosition>[];
    for (final row in dto.affectedRecordRows) {
      final rowRemoteId = row.id;
      final rowPosition = row.newPosition;
      if (rowRemoteId == null || rowPosition == null) {
        _log.w('Skipping invalid affected record row in dto: $row');
        continue;
      }
      final affectedLocalId = localIdByRemoteId[rowRemoteId];
      if (affectedLocalId == null) {
        _log.w(
          'Skipping affected record: remoteId=$rowRemoteId not found locally (tag=$tag)',
        );
        continue;
      }
      affectedRecords.add(
        RecordWithPosition(id: affectedLocalId, position: rowPosition),
      );
    }

    _log.i(
      'Position update received; updating local registry '
      '(remoteId=$remoteId localId=$localId newPosition=$newPosition affected=${affectedRecords.length})',
    );

    try {
      await _mediaRegistryService.updatePosition(
        UpdatePositionRequest(
          currentRecord: RecordWithPosition(id: localId, position: newPosition),
          affectedRecords: affectedRecords,
        ),
      );
    } catch (e, st) {
      _log.e(
        'Failed to update local media positions from PositionUpdatedEventDto',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
