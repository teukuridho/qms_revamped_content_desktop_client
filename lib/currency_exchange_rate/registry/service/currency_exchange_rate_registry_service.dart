import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/orderable/request/update_position_request.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/event/currency_exchange_rate_created_event.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/event/currency_exchange_rate_deleted_event.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/event/currency_exchange_rate_mass_position_updated_event.dart';
import 'package:qms_revamped_content_desktop_client/currency_exchange_rate/registry/request/create_currency_exchange_rate_request.dart';

class CurrencyExchangeRateRegistryService {
  static final AppLog _log = AppLog('currency_exchange_rate_registry');

  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  CurrencyExchangeRateRegistryService({
    required AppDatabaseManager appDatabaseManager,
    required EventManager eventManager,
  }) {
    _appDatabaseManager = appDatabaseManager;
    _eventManager = eventManager;
  }

  Future<CurrencyExchangeRate> create(
    CreateCurrencyExchangeRateRequest request,
  ) async {
    final appDatabase = _appDatabaseManager.appDatabase;
    _log.i(
      'create(remoteId=${request.remoteId} position=${request.position} tag=${request.tag})',
    );
    final row = await appDatabase
        .into(appDatabase.currencyExchangeRates)
        .insertReturning(
          CurrencyExchangeRatesCompanion.insert(
            remoteId: request.remoteId,
            flagImageId: Value(request.flagImageId),
            flagImagePath: Value(request.flagImagePath),
            countryName: request.countryName,
            currencyCode: request.currencyCode,
            buy: request.buy,
            sell: request.sell,
            position: request.position,
            tag: request.tag,
          ),
        );

    _eventManager.publishEvent(
      CurrencyExchangeRateCreatedEvent(currencyExchangeRate: row),
    );
    return row;
  }

  Future<List<CurrencyExchangeRate>> getAllByTagOrdered({
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    _log.d('getAllByTagOrdered(tag=$tag)');
    return (db.select(db.currencyExchangeRates)
          ..where((e) => e.tag.equals(tag))
          ..orderBy([
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .get();
  }

  Stream<List<CurrencyExchangeRate>> watchAllByTagOrdered({
    required String tag,
  }) {
    final db = _appDatabaseManager.appDatabase;
    return (db.select(db.currencyExchangeRates)
          ..where((e) => e.tag.equals(tag))
          ..orderBy([
            (e) => OrderingTerm.asc(e.position),
            (e) => OrderingTerm.asc(e.id),
          ]))
        .watch();
  }

  Future<CurrencyExchangeRate?> getOneByRemoteId({
    required int remoteId,
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    return (await (db.select(db.currencyExchangeRates)
              ..where((e) => e.remoteId.equals(remoteId) & e.tag.equals(tag))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<CurrencyExchangeRate?> getOneById({required int id}) async {
    final db = _appDatabaseManager.appDatabase;
    return (await (db.select(db.currencyExchangeRates)
              ..where((e) => e.id.equals(id))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<CurrencyExchangeRate> upsertByRemoteId({
    required int remoteId,
    required int? flagImageId,
    required String? flagImagePath,
    required String countryName,
    required String currencyCode,
    required double buy,
    required double sell,
    required int position,
    required String tag,
  }) async {
    final db = _appDatabaseManager.appDatabase;
    final existing = await getOneByRemoteId(remoteId: remoteId, tag: tag);

    if (existing == null) {
      return create(
        CreateCurrencyExchangeRateRequest(
          remoteId: remoteId,
          flagImageId: flagImageId,
          flagImagePath: flagImagePath,
          countryName: countryName,
          currencyCode: currencyCode,
          buy: buy,
          sell: sell,
          position: position,
          tag: tag,
        ),
      );
    }

    _log.i('upsertByRemoteId(update remoteId=$remoteId tag=$tag)');
    final updated =
        (await (db.update(
              db.currencyExchangeRates,
            )..where((e) => e.id.equals(existing.id))).writeReturning(
              CurrencyExchangeRatesCompanion(
                flagImageId: Value(flagImageId),
                flagImagePath: Value(flagImagePath),
                countryName: Value(countryName),
                currencyCode: Value(currencyCode),
                buy: Value(buy),
                sell: Value(sell),
                position: Value(position),
              ),
            ))
            .first;

    _eventManager.publishEvent(
      CurrencyExchangeRateCreatedEvent(currencyExchangeRate: updated),
    );
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
      await ((appDatabase.update(
        appDatabase.currencyExchangeRates,
      )..where((e) => e.id.equals(record.id))).write(
        CurrencyExchangeRatesCompanion(position: Value(record.position)),
      ));
    }
    _eventManager.publishEvent(
      CurrencyExchangeRateMassPositionUpdatedEvent(list: list),
    );
  }

  Future<void> delete(int id) async {
    final appDatabase = _appDatabaseManager.appDatabase;
    _log.i('delete(id=$id)');
    await (appDatabase.delete(
      appDatabase.currencyExchangeRates,
    )..where((e) => e.id.equals(id))).go();

    _eventManager.publishEvent(CurrencyExchangeRateDeletedEvent(id: id));
  }
}
