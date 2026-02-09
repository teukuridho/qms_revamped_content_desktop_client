import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_created_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_deleted_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/event/media_mass_position_updated_event.dart';
import 'package:qms_revamped_content_desktop_client/media/registry/request/create_media_request.dart';

class MediaRegistryService {
  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  Future<MediaData> create(CreateMediaRequest request) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
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

  Future<void> updatePosition(UpdatePositionRequest request)  async {
    List<RecordWithPosition> toUpdate = [...request.affectedRecords];
    toUpdate.add(request.currentRecord);

    _updateMassPositions(toUpdate);

    return;
  }

  Future<void> _updateMassPositions(List<RecordWithPosition> list) async{
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;

    for(RecordWithPosition record in list) {
      (await ((appDatabase.update(appDatabase.media)..where((e) => e.id.equals(record.id))).write(MediaCompanion(
          position: Value(record.position)
      ))));

      _eventManager.publishEvent(MediaMassPositionUpdatedEvent(list: list));
    }
  }

  Future<void> delete(int id) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
    await (appDatabase.delete(appDatabase.media)..where((e) => e.id.equals(id))).go();

    _eventManager.publishEvent(MediaDeletedEvent(id: id));
  }
}
