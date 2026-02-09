import 'package:drift/drift.dart';

class ServerProperties extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serviceName => text()();
  TextColumn get serverAddress => text()();

  // Keycloak / OIDC configuration (per serviceName)
  TextColumn get keycloakBaseUrl =>
      text().withDefault(const Constant(''))(); // e.g. https://id.example.com
  TextColumn get keycloakRealm =>
      text().withDefault(const Constant(''))(); // e.g. my-realm
  TextColumn get keycloakClientId =>
      text().withDefault(const Constant(''))(); // public client id

  // Persisted token set (Bearer tokens, no cookies)
  TextColumn get oidcAccessToken => text().withDefault(const Constant(''))();
  TextColumn get oidcRefreshToken => text().withDefault(const Constant(''))();
  TextColumn get oidcIdToken => text().withDefault(const Constant(''))();
  IntColumn get oidcExpiresAtEpochMs =>
      integer().withDefault(const Constant(0))(); // access token expiry
  TextColumn get oidcScope => text().withDefault(const Constant(''))();
  TextColumn get oidcTokenType => text().withDefault(const Constant(''))();
}
