# AUTH_PROMPT.md — Keycloak Login Integration (Flutter Desktop Signage)

Repo: `qms_revamped_content_desktop_client`

## Objective
Add Keycloak-based authentication usable by multiple “service components” (media / running text / product / exchange rate / …) identified by `serviceName`.

Implement **two login flows**:

### Option 1 — Browser Login + Loopback Redirect (Authorization Code + PKCE)
- Flutter opens system browser to Keycloak login UI.
- Flutter starts an embedded HTTP listener on `127.0.0.1:<random_port>` for the redirect.
- Exchange `code` for tokens.

### Option 2 — QR Login (Device Authorization Grant)
- Flutter requests a `device_code` from Keycloak.
- Flutter renders QR from `verification_uri_complete` (or `verification_uri` + `user_code`).
- Operator scans QR on phone/PC, logs in via Keycloak UI, approves device.
- Flutter polls token endpoint until tokens are issued.

Tokens must support **`offline_access`** (target retention ~10 years via realm session settings).

---

## Constraints & Design Choices
- Keycloak base URL / realm / client id are **configurable per `serviceName`**.
- Use **Bearer tokens** (no cookies) for API calls.
- No “pairing service”; QR flow uses **Keycloak device flow directly**.
- Persist tokens so the device can boot and run without an operator.
- Keep the API generic so new components can reuse auth with only a `serviceName`.
- `server_properties` does not store legacy basic-auth fields (`username`, `password`, `cookie`).

---

## Existing Code Touchpoints
- `lib/core/auth/auth_service.dart` → OIDC auth implementation (browser PKCE + device QR).
- `lib/core/server_properties/registry/entity/server_properties.dart` → extend table with Keycloak + token fields.
- `lib/core/server_properties/registry/service/server_properties_registry_service.dart` → add getters/setters for Keycloak config & tokens.
- `lib/core/server_properties/form/ui/view_model/server_properties_form_view_model.dart` and `.../view/server_properties_form_view.dart` → add Keycloak fields + login actions UI.
- `lib/core/database/app_database.dart` → bump schemaVersion + migration.
- `drift_schemas/my_database/drift_schema_v*.json` → generate v7 schema.

---

## Keycloak Client Requirements (document these in UI/help text)
For the client used by this desktop app (a new Keycloak client):

- Type: **OpenID Connect**, **Public client**
- Enable:
    - ✅ Standard Flow (for PKCE option)
    - ✅ OAuth 2.0 Device Authorization Grant (for QR option)
- Disable:
    - ❌ Implicit flow
    - ❌ Direct access grants (password grant)
- PKCE:
    - Require **S256**
- Redirect URIs (for loopback option, Keycloak 26.1+):
    - Add exactly `http://127.0.0.1/*`
      Keycloak treats this as a special-case loopback redirect and allows any port (native app pattern).
- Add client scope:
    - `offline_access` (Default preferred)

Realm settings (for “~10 years” offline sessions):
- Realm → Sessions:
    - Offline Session Idle: `3650 days` (or desired)
    - Offline Session Max Limited: **OFF**

---

## Data Model Changes (Drift)
Update `ServerProperties` table to store Keycloak config and tokens per `serviceName`.

### Add columns (all NOT NULL with default empty/zero during migration)
Add to `lib/core/server_properties/registry/entity/server_properties.dart`:

- `keycloakBaseUrl` (text)
- `keycloakRealm` (text)
- `keycloakClientId` (text)
- `oidcAccessToken` (text)
- `oidcRefreshToken` (text)
- `oidcIdToken` (text) (optional; store empty if unused)
- `oidcExpiresAtEpochMs` (int)  // access token expiry timestamp
- `oidcScope` (text)
- `oidcTokenType` (text)

Notes:
- This repo currently stores secrets in SQLite; keep it consistent. (Optionally later migrate refresh token to secure storage.)
- Removed legacy basic-auth columns (dropped in schema v7):
  - `username`, `password`, `cookie`

### DB migration
In `lib/core/database/app_database.dart`:
- Bump `schemaVersion` from `5` → `6`:
  - Add `from5To6` migration: add new Keycloak/OIDC columns to `server_properties` with safe defaults.
- Bump `schemaVersion` from `6` → `7`:
  - Add `from6To7` migration: drop `username`, `password`, `cookie` from `server_properties`.

After schema change:
- Run build runner to regenerate:
    - `lib/core/database/app_database.g.dart`
    - `lib/core/database/app_database.steps.dart`
- Generate a new drift schema snapshot:
    - `drift_schemas/my_database/drift_schema_v7.json`

---

## Auth Core: New Classes
Create folder: `lib/core/auth/oidc/`

### 1) Models
Create `lib/core/auth/oidc/model/oidc_config.dart`:
- `OidcConfig { baseUrl, realm, clientId }`

Create `lib/core/auth/oidc/model/token_set.dart`:
- `OidcTokenSet { accessToken, refreshToken, idToken, expiresAt, scope, tokenType }`

Create `lib/core/auth/oidc/model/device_authorization.dart`:
- `DeviceAuthorization { deviceCode, userCode, verificationUri, verificationUriComplete, expiresIn, interval }`

### 2) Endpoints helper
Create `lib/core/auth/oidc/oidc_endpoints.dart`:
- Build endpoints from config:
    - authorization endpoint: `${baseUrl}/realms/${realm}/protocol/openid-connect/auth`
    - token endpoint: `${baseUrl}/realms/${realm}/protocol/openid-connect/token`
    - device authorization endpoint: `${baseUrl}/realms/${realm}/protocol/openid-connect/auth/device`

Ensure baseUrl normalization (no trailing slash).

### 3) PKCE helper
Create `lib/core/auth/oidc/pkce.dart`:
- Generate `codeVerifier` (random 32-64 bytes base64url no padding)
- `codeChallenge = base64url(sha256(codeVerifier))`

### 4) Embedded loopback server
Create `lib/core/auth/oidc/loopback_server.dart`:
- Start `HttpServer.bind(InternetAddress.loopbackIPv4, 0)`
- Provide:
    - `redirectUri` (http://127.0.0.1:<port>/)
    - `Future<Uri> waitForRedirect({Duration timeout})` returns callback URL containing `code` and `state`
- Respond to browser with a simple HTML “Login completed, you may close this window.”
- Shut down server after receiving callback.
- Callback matching should not rely on a fixed path (accept OAuth query parameters on any path).

### 5) OIDC client (no UI)
Create `lib/core/auth/oidc/keycloak_oidc_client.dart`:
Implements raw HTTP calls using `package:http/http.dart`.

Implementation notes:
- Add reasonable per-request timeouts to avoid stuck polling on network issues.
- Log request outcomes (status code) without logging tokens.

Methods:
- `Future<OidcTokenSet> exchangeCodeForTokens(...)`
- `Future<OidcTokenSet> refreshTokens(...)`
- `Future<DeviceAuthorization> startDeviceAuthorization(...)`
- `Future<OidcTokenSet> pollDeviceTokens(...)` (one poll)

Handle JSON + OAuth error responses.

### 6) Auth service (per serviceName)
Replace `lib/core/auth/auth_service.dart` with `OidcAuthService` logic.

Responsibilities:
- Load `ServerProperty` for `serviceName`.
- Read OIDC config fields.
- Execute login flows.
- Persist token fields back to DB for that `serviceName`.
- Provide `getValidAccessToken()` that refreshes automatically.
- Emit an `AuthLoggedInEvent` via `EventManager` on successful login (include `serviceName` + metadata, do not include raw tokens).
- Add logs for all auth operations.

Public API (minimum):
- `Future<void> loginWithBrowserPkce()`
- `Future<DeviceAuthorization> startQrLogin()`
- `Future<void> completeQrLoginByPolling(DeviceAuthorization da)`
- `Future<String?> getValidAccessToken()`
- `Future<void> logout()` (clears tokens)
- `Future<void> cancelBrowserLogin()` (optional, for UX retries)

---

## OAuth Request/Response Details (Keycloak)

### Option 1 — PKCE Browser Flow

1) Start loopback server, compute redirect URI.
2) Build authorization URL:

Parameters:
- `client_id`
- `response_type=code`
- `scope=openid offline_access`
- `redirect_uri=<loopback>` (e.g. `http://127.0.0.1:<random_port>/`)
- `code_challenge=<S256>`
- `code_challenge_method=S256`
- `state=<random>`

3) Open browser via `url_launcher`.
4) Wait for callback: `http://127.0.0.1:<port>/?code=...&state=...`
5) Token exchange:

POST token endpoint (x-www-form-urlencoded):
- `grant_type=authorization_code`
- `client_id=<clientId>`
- `code=<code>`
- `redirect_uri=<loopback>`
- `code_verifier=<verifier>`

Response JSON (store at least these):
- `access_token`
- `expires_in`
- `refresh_token`
- `token_type`
- `scope`
- `id_token` (optional)


### Option 2 — Device Flow (QR)

1) Request device authorization:

POST device endpoint (x-www-form-urlencoded):
- `client_id=<clientId>`
- `scope=openid offline_access`

Response JSON:
- `device_code`
- `user_code`
- `verification_uri`
- `verification_uri_complete` (preferred)
- `expires_in`
- `interval`

2) Show QR of `verification_uri_complete` (or show `verification_uri` + `user_code`).
3) Poll token endpoint until success or terminal error:

POST token endpoint:
- `grant_type=urn:ietf:params:oauth:grant-type:device_code`
- `device_code=<device_code>`
- `client_id=<clientId>`

Possible error responses (handle):
- `authorization_pending` → keep polling
- `slow_down` → increase interval (e.g., +5s)
- `expired_token` → fail & restart
- `access_denied` → fail & restart

On success: same token fields as above.


### Refresh tokens
POST token endpoint:
- `grant_type=refresh_token`
- `client_id=<clientId>`
- `refresh_token=<stored refresh token>`

If error `invalid_grant`, clear stored tokens and require login again.

---

## UI Integration

### Where to integrate
Current UI entrypoint is `MainScreen` → `ServerPropertiesFormScreen` → `ServerPropertiesFormView`.

Update this form to support:
- Editing Keycloak config fields (baseUrl/realm/clientId)
- Buttons:
    - “Login (Browser)” → Option 1
    - “Login (QR)” → Option 2
    - “Logout / Clear Tokens”

UX notes:
- Show snackbars on login success/failure.
- Auto-start QR login on startup if Keycloak config is already present and the device is not logged in.
- Show helper text (example): “Please connect your phone to the same network/VPN as this computer, then scan the QR to sign in.”

### UI Components to add
Create `lib/core/auth/ui/auth_section.dart`:
- Stateless/widget that consumes an `AuthViewModel`.

Create `lib/core/auth/ui/view_model/auth_view_model.dart`:
- Depends on `OidcAuthService` and `serviceName`.
- Exposes `ProcessState` for:
    - loginBrowserState
    - startQrState
    - pollQrState
- Stores last `DeviceAuthorization` result to render:
    - QR string
    - manual URL + code
    - countdown from `expires_in`

Update `ServerPropertiesFormViewModel`:
- Add controllers for:
    - keycloakBaseUrl
    - keycloakRealm
    - keycloakClientId
- Load/save them to DB.

Update `ServerPropertiesFormView`:
- Render the new Keycloak fields.
- Render `AuthSection` below the config.

### QR rendering
Add dependency `qr_flutter` and render QR for `verification_uri_complete`.
Also show a manual fallback:
- `verification_uri`
- `user_code`

---

## Dependency Updates
In `pubspec.yaml` add:
- `http`
- `crypto`
- `url_launcher`
- `qr_flutter`

(If later moving refresh token to OS keystore, add `flutter_secure_storage`.)

---

## Provider/DI Wiring
In `lib/main.dart` providers list, add:

- `Provider(create: (_) => OidcAuthServiceFactory(...))` OR
- simplest: `Provider(create: (context) => OidcAuthService(serviceName: 'test', serverPropertiesRegistryService: context.read()))` for the initial screen.

Preferred scalable approach:
- Create `OidcAuthServiceFactory` that returns `OidcAuthService(serviceName: X)`.
- Inject factory into view models.

Event wiring:
- Ensure `EventManager` is injected into `OidcAuthService` so it can emit `AuthLoggedInEvent`.
- Listen with `eventManager.listen<AuthLoggedInEvent>()` where needed.

---

## Acceptance Criteria

### Option 1 (PKCE)
1) Configure Keycloak baseUrl/realm/clientId.
2) Click “Login (Browser)”.
3) Browser opens Keycloak login UI.
4) After successful login, browser redirects to loopback and shows “You can close this window”.
5) App stores tokens in DB and shows “Logged in”.
6) Restart app → tokens are still present.
7) When access token expires, calling `getValidAccessToken()` refreshes automatically.

### Option 2 (QR Device Flow)
1) Click “Login (QR)”.
2) App shows QR + manual URL/code.
3) Scan QR and complete login.
4) App polls and transitions to “Logged in”.
5) Restart app → tokens still valid via refresh.

### Revocation handling
- If refresh fails with `invalid_grant`, app clears stored tokens and returns to “Please login” state.

---

## Implementation Notes / Gotchas
- Always normalize Keycloak base URL (strip trailing `/`).
- Use `127.0.0.1` loopback instead of `localhost` to avoid DNS issues.
- In PKCE callback, validate `state`.
- Timeouts:
    - PKCE wait-for-callback timeout (e.g., 3–5 minutes)
    - Device flow expires based on `expires_in`
- For `slow_down`, increase polling delay and respect server interval.

---

## Deliverables
- Working login flows (Option 1 + Option 2) on Windows/Linux/macOS.
- Token persistence per `serviceName`.
- Updated drift schema (v7) and generated code.
- UI that supports configuring Keycloak settings and executing login flows.
