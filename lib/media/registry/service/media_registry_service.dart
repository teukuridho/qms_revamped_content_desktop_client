import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_created_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_deleted_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_mass_position_updated_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/request/create_media_request.dart';

class MediaRegistryService {
  static final AppLog _log = AppLog('media_registry');

  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  MediaRegistryService({
    required AppDatabaseManager appDatabaseManager,
    required EventManager eventManager,
  }) {
    _appDatabaseManager = appDatabaseManager;
    _eventManager = eventManager;
  }

  Future<MediaData> create(CreateMediaRequest request) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
    _log.i(
      'create(remoteId=${request.remoteId} position=${request.position} tag=${request.tag})',
    );
    MediaData media = await appDatabase
        .into(appDatabase.media)
        .insertReturning(
          MediaCompanion.insert(
            remoteId: request.remoteId,
            path: request.path,
            position: request.position,
            contentType: request.contentType,
            mimeType: request.mimeType,
            tag: request.tag,
          ),
        );

    _eventManager.publishEvent(MediaCreatedEvent(media: media));

    return media;
  }

  Future<List<MediaData>> getAllByTagOrdered({required String tag}) async {
    final db = _appDatabaseManager.appDatabase;
    _log.d('getAllByTagOrdered(tag=$tag)');
    return (db.select(db.media)
          ..where((e) => e.tag.equals(tag))
          ..orderBy([
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .get();
  }

  Future<MediaData?> getOneByRemoteId({
    required int remoteId,
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    _log.d('getOneByRemoteId(remoteId=$remoteId tag=$tag)');
    return (await (db.select(db.media)
              ..where((e) => e.remoteId.equals(remoteId) & e.tag.equals(tag))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<MediaData?> getOneById({required int id}) async {
    final db = _appDatabaseManager.appDatabase;
    _log.d('getOneById(id=$id)');
    return (await (db.select(db.media)
              ..where((e) => e.id.equals(id))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<MediaData> upsertByRemoteId({
    required int remoteId,
    required String path,
    required int position,
    required String contentType,
    required String mimeType,
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    final existing = await getOneByRemoteId(remoteId: remoteId, tag: tag);

    if (existing == null) {
      return create(
        CreateMediaRequest(
          remoteId: remoteId,
          path: path,
          position: position,
          contentType: contentType,
          mimeType: mimeType,
          tag: tag,
        ),
      );
    }

    _log.i(
      'upsertByRemoteId(update remoteId=$remoteId tag=$tag id=${existing.id})',
    );
    final updated =
        (await (db.update(
              db.media,
            )..where((e) => e.id.equals(existing.id))).writeReturning(
              MediaCompanion(
                path: Value(path),
                position: Value(position),
                contentType: Value(contentType),
                mimeType: Value(mimeType),
              ),
            ))
            .first;

    // Mirror create/delete semantics for consumers that care about changes.
    _eventManager.publishEvent(MediaCreatedEvent(media: updated));
    return updated;
  }

  Future<void> deleteByRemoteId({
    required int remoteId,
    required String tag,
  }) async {
    final existing = await getOneByRemoteId(remoteId: remoteId, tag: tag);
    if (existing == null) return;
    await delete(existing.id);
  }

  Future<void> updatePosition(UpdatePositionRequest request) async {
    _log.d(
      'updatePosition(currentId=${request.currentRecord.id} affected=${request.affectedRecords.length})',
    );
    final toUpdate = <RecordWithPosition>[...request.affectedRecords];
    toUpdate.add(request.currentRecord);

    await _updateMassPositions(toUpdate);
  }

  Future<void> _updateMassPositions(List<RecordWithPosition> list) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;

    for (RecordWithPosition record in list) {
      (await ((appDatabase.update(appDatabase.media)
            ..where((e) => e.id.equals(record.id)))
          .write(MediaCompanion(position: Value(record.position)))));
    }
    _eventManager.publishEvent(MediaMassPositionUpdatedEvent(list: list));
  }

  Future<void> delete(int id) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
    _log.i('delete(id=$id)');
    await (appDatabase.delete(
      appDatabase.media,
    )..where((e) => e.id.equals(id))).go();

    _eventManager.publishEvent(MediaDeletedEvent(id: id));
  }
}
