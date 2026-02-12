import 'package:drift/drift.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database.dart';
import 'package:qms_revamped_content_desktop_client/core/database/app_database_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/event_manager/event_manager.dart';
import 'package:qms_revamped_content_desktop_client/core/logging/app_log.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/event/server_properties_created_event.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/event/server_properties_updated_event.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/create_server_properties_request.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/registry/request/update_service_by_name_request.dart';

class ServerPropertiesRegistryService {
  static final AppLog _log = AppLog('server_properties');

  late final AppDatabaseManager _appDatabaseManager;
  late final EventManager _eventManager;

  ServerPropertiesRegistryService({
    required AppDatabaseManager appDatabaseManager,
    required EventManager eventManager,
  }) {
    _appDatabaseManager = appDatabaseManager;
    _eventManager = eventManager;
  }

  Future<ServerProperty?> getOneByServiceNameAndTag({
    required String serviceName,
    required String tag,
  }) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
    _log.d('getOneByServiceNameAndTag(serviceName=$serviceName tag=$tag)');

    return (await (appDatabase.select(appDatabase.serverProperties)
              ..where(
                (e) => e.serviceName.equals(serviceName) & e.tag.equals(tag),
              )
              ..limit(1))
            .get())
        .firstOrNull;
  }

  Future<ServerProperty> create(CreateServerPropertiesRequest request) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
    _log.i('create(serviceName=${request.serviceName} tag=${request.tag})');

    ServerProperty result = await appDatabase
        .into(appDatabase.serverProperties)
        .insertReturning(
          ServerPropertiesCompanion.insert(
            serviceName: request.serviceName,
            tag: Value(request.tag),
            serverAddress: request.serverAddress,
            keycloakBaseUrl: Value(request.keycloakBaseUrl),
            keycloakRealm: Value(request.keycloakRealm),
            keycloakClientId: Value(request.keycloakClientId),
          ),
        );

    _eventManager.publishEvent(ServerPropertiesCreatedEvent(result));

    return result;
  }

  Future<ServerProperty?> updateByServiceNameAndTag(
    UpdateServiceByNameRequest request,
  ) async {
    AppDatabase appDatabase = _appDatabaseManager.appDatabase;
    _log.i(
      'updateByServiceNameAndTag(serviceName=${request.serviceName} tag=${request.tag} '
      'serverAddress=${request.serverAddress == null ? "<unchanged>" : "<updated>"} '
      'keycloak=<updated=${request.keycloakBaseUrl != null || request.keycloakRealm != null || request.keycloakClientId != null}> '
      'tokens=<access=${request.oidcAccessToken == null ? "unchanged" : (request.oidcAccessToken!.isEmpty ? "cleared" : "set")} '
      'refresh=${request.oidcRefreshToken == null ? "unchanged" : (request.oidcRefreshToken!.isEmpty ? "cleared" : "set")}>'
      ')',
    );

    ServerProperty? result =
        (await (appDatabase.update(appDatabase.serverProperties)..where(
                  (e) =>
                      e.serviceName.equals(request.serviceName) &
                      e.tag.equals(request.tag),
                ))
                .writeReturning(
                  ServerPropertiesCompanion(
                    serverAddress: Value.absentIfNull(request.serverAddress),
                    keycloakBaseUrl: Value.absentIfNull(
                      request.keycloakBaseUrl,
                    ),
                    keycloakRealm: Value.absentIfNull(request.keycloakRealm),
                    keycloakClientId: Value.absentIfNull(
                      request.keycloakClientId,
                    ),
                    oidcAccessToken: Value.absentIfNull(
                      request.oidcAccessToken,
                    ),
                    oidcRefreshToken: Value.absentIfNull(
                      request.oidcRefreshToken,
                    ),
                    oidcIdToken: Value.absentIfNull(request.oidcIdToken),
                    oidcExpiresAtEpochMs: Value.absentIfNull(
                      request.oidcExpiresAtEpochMs,
                    ),
                    oidcScope: Value.absentIfNull(request.oidcScope),
                    oidcTokenType: Value.absentIfNull(request.oidcTokenType),
                  ),
                ))
            .firstOrNull;

    if (result != null) {
      _eventManager.publishEvent(ServerPropertiesUpdatedEvent(result));
    }

    return result;
  }
}
