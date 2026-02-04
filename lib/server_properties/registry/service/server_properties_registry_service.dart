import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/database/app_database_manager.dart';

class ServerPropertiesRegistryService {
  late final AppDatabaseManager _appDatabaseManager;

  ServerPropertiesRegistryService({
    required AppDatabaseManager appDatabaseManager,
  }) {
    _appDatabaseManager = appDatabaseManager;
  }

  Future<ServerProperty?> getOneByServiceName({
    required String serviceName,
  }) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;

    return (await (appDatabase.select(appDatabase.serverProperties)
              ..where((e) => e.serviceName.equals(serviceName))
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<ServerProperty> create({
    required String serviceName,
    required String serverAddress,
    required String username,
    required String password
  }) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;

    ServerProperty result = await appDatabase
        .into(appDatabase.serverProperties)
        .insertReturning(
          ServerPropertiesCompanion.insert(
            serviceName: serviceName,
            serverAddress: serverAddress,
            username: username,
            password: password,
            cookie: "",
          ),
        );

    return result;
  }

  Future<ServerProperty?> updateByServiceName({
    required String serviceName,
    String? serverAddress,
    String? username,
    String? password,
    String? cookies,
  }) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;

    return (await (appDatabase.update(
          appDatabase.serverProperties,
        )..where((e) => e.serviceName.equals(serviceName))).writeReturning(
          ServerPropertiesCompanion(
            serverAddress: Value.absentIfNull(serverAddress),
            username: Value.absentIfNull(username),
            password: Value.absentIfNull(password),
            cookie: Value.absentIfNull(cookies),
          ),
        ))
        .firstOrNull;
  }
}
