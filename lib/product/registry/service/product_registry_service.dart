import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/event/product_created_event.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/event/product_deleted_event.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/event/product_mass_position_updated_event.dart';
import 'package:qms_revamped_content_desktop_client/product/registry/request/create_product_request.dart';

class ProductRegistryService {
  static final AppLog _log = AppLog('product_registry');

  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  ProductRegistryService({
    required AppDatabaseManager appDatabaseManager,
    required EventManager eventManager,
  }) {
    _appDatabaseManager = appDatabaseManager;
    _eventManager = eventManager;
  }

  Future<Product> create(CreateProductRequest request) async {
    final appDatabase = _appDatabaseManager.appDatabase;
    _log.i(
      'create(remoteId=${request.remoteId} position=${request.position} tag=${request.tag})',
    );
    final row = await appDatabase
        .into(appDatabase.products)
        .insertReturning(
          ProductsCompanion.insert(
            remoteId: request.remoteId,
            name: request.name,
            value: request.value,
            position: request.position,
            tag: request.tag,
          ),
        );

    _eventManager.publishEvent(ProductCreatedEvent(product: row));
    return row;
  }

  Future<List<Product>> getAllByTagOrdered({required String tag}) async {
    final db = _appDatabaseManager.appDatabase;
    _log.d('getAllByTagOrdered(tag=$tag)');
    return (db.select(db.products)
          ..where((e) => e.tag.equals(tag))
          ..orderBy([
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .get();
  }

  Stream<List<Product>> watchAllByTagOrdered({required String tag}) {
    final db = _appDatabaseManager.appDatabase;
    return (db.select(db.products)
          ..where((e) => e.tag.equals(tag))
          ..orderBy([
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .watch();
  }

  Future<Product?> getOneByRemoteId({
    required int remoteId,
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    return (await (db.select(db.products)
              ..where((e) => e.remoteId.equals(remoteId) & e.tag.equals(tag))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<Product?> getOneById({required int id}) async {
    final db = _appDatabaseManager.appDatabase;
    return (await (db.select(db.products)
              ..where((e) => e.id.equals(id))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<Product> upsertByRemoteId({
    required int remoteId,
    required String name,
    required String value,
    required int position,
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    final existing = await getOneByRemoteId(remoteId: remoteId, tag: tag);

    if (existing == null) {
      return create(
        CreateProductRequest(
          remoteId: remoteId,
          name: name,
          value: value,
          position: position,
          tag: tag,
        ),
      );
    }

    _log.i('upsertByRemoteId(update remoteId=$remoteId tag=$tag)');
    final updated =
        (await (db.update(
              db.products,
            )..where((e) => e.id.equals(existing.id))).writeReturning(
              ProductsCompanion(
                name: Value(name),
                value: Value(value),
                position: Value(position),
              ),
            ))
            .first;

    _eventManager.publishEvent(ProductCreatedEvent(product: updated));
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
    final toUpdate = <RecordWithPosition>[...request.affectedRecords];
    toUpdate.add(request.currentRecord);
    await _updateMassPositions(toUpdate);
  }

  Future<void> _updateMassPositions(List<RecordWithPosition> list) async {
    final appDatabase = _appDatabaseManager.appDatabase;
    for (final record in list) {
      await ((appDatabase.update(appDatabase.products)
            ..where((e) => e.id.equals(record.id)))
          .write(ProductsCompanion(position: Value(record.position))));
    }
    _eventManager.publishEvent(ProductMassPositionUpdatedEvent(list: list));
  }

  Future<void> delete(int id) async {
    final appDatabase = _appDatabaseManager.appDatabase;
    _log.i('delete(id=$id)');
    await (appDatabase.delete(
      appDatabase.products,
    )..where((e) => e.id.equals(id))).go();

    _eventManager.publishEvent(ProductDeletedEvent(id: id));
  }
}
