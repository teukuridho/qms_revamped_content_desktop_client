// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MediaTable extends Media with TableInfo<$MediaTable, MediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    path,
    position,
    contentType,
    mimeType,
    tag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $MediaTable createAlias(String alias) {
    return $MediaTable(attachedDatabase, alias);
  }
}

class MediaData extends DataClass implements Insertable<MediaData> {
  final int id;
  final int remoteId;
  final String path;
  final int position;
  final String contentType;
  final String mimeType;
  final String tag;
  const MediaData({
    required this.id,
    required this.remoteId,
    required this.path,
    required this.position,
    required this.contentType,
    required this.mimeType,
    required this.tag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['remote_id'] = Variable<int>(remoteId);
    map['path'] = Variable<String>(path);
    map['position'] = Variable<int>(position);
    map['content_type'] = Variable<String>(contentType);
    map['mime_type'] = Variable<String>(mimeType);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  MediaCompanion toCompanion(bool nullToAbsent) {
    return MediaCompanion(
      id: Value(id),
      remoteId: Value(remoteId),
      path: Value(path),
      position: Value(position),
      contentType: Value(contentType),
      mimeType: Value(mimeType),
      tag: Value(tag),
    );
  }

  factory MediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaData(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      path: serializer.fromJson<String>(json['path']),
      position: serializer.fromJson<int>(json['position']),
      contentType: serializer.fromJson<String>(json['contentType']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int>(remoteId),
      'path': serializer.toJson<String>(path),
      'position': serializer.toJson<int>(position),
      'contentType': serializer.toJson<String>(contentType),
      'mimeType': serializer.toJson<String>(mimeType),
      'tag': serializer.toJson<String>(tag),
    };
  }

  MediaData copyWith({
    int? id,
    int? remoteId,
    String? path,
    int? position,
    String? contentType,
    String? mimeType,
    String? tag,
  }) => MediaData(
    id: id ?? this.id,
    remoteId: remoteId ?? this.remoteId,
    path: path ?? this.path,
    position: position ?? this.position,
    contentType: contentType ?? this.contentType,
    mimeType: mimeType ?? this.mimeType,
    tag: tag ?? this.tag,
  );
  MediaData copyWithCompanion(MediaCompanion data) {
    return MediaData(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      path: data.path.present ? data.path.value : this.path,
      position: data.position.present ? data.position.value : this.position,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaData(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('path: $path, ')
          ..write('position: $position, ')
          ..write('contentType: $contentType, ')
          ..write('mimeType: $mimeType, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteId, path, position, contentType, mimeType, tag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaData &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.path == this.path &&
          other.position == this.position &&
          other.contentType == this.contentType &&
          other.mimeType == this.mimeType &&
          other.tag == this.tag);
}

class MediaCompanion extends UpdateCompanion<MediaData> {
  final Value<int> id;
  final Value<int> remoteId;
  final Value<String> path;
  final Value<int> position;
  final Value<String> contentType;
  final Value<String> mimeType;
  final Value<String> tag;
  const MediaCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.path = const Value.absent(),
    this.position = const Value.absent(),
    this.contentType = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.tag = const Value.absent(),
  });
  MediaCompanion.insert({
    this.id = const Value.absent(),
    required int remoteId,
    required String path,
    required int position,
    required String contentType,
    required String mimeType,
    required String tag,
  }) : remoteId = Value(remoteId),
       path = Value(path),
       position = Value(position),
       contentType = Value(contentType),
       mimeType = Value(mimeType),
       tag = Value(tag);
  static Insertable<MediaData> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<String>? path,
    Expression<int>? position,
    Expression<String>? contentType,
    Expression<String>? mimeType,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (path != null) 'path': path,
      if (position != null) 'position': position,
      if (contentType != null) 'content_type': contentType,
      if (mimeType != null) 'mime_type': mimeType,
      if (tag != null) 'tag': tag,
    });
  }

  MediaCompanion copyWith({
    Value<int>? id,
    Value<int>? remoteId,
    Value<String>? path,
    Value<int>? position,
    Value<String>? contentType,
    Value<String>? mimeType,
    Value<String>? tag,
  }) {
    return MediaCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      path: path ?? this.path,
      position: position ?? this.position,
      contentType: contentType ?? this.contentType,
      mimeType: mimeType ?? this.mimeType,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('path: $path, ')
          ..write('position: $position, ')
          ..write('contentType: $contentType, ')
          ..write('mimeType: $mimeType, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

class $ServerPropertiesTable extends ServerProperties
    with TableInfo<$ServerPropertiesTable, ServerProperty> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerPropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _serviceNameMeta = const VerificationMeta(
    'serviceName',
  );
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
    'service_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverAddressMeta = const VerificationMeta(
    'serverAddress',
  );
  @override
  late final GeneratedColumn<String> serverAddress = GeneratedColumn<String>(
    'server_address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keycloakBaseUrlMeta = const VerificationMeta(
    'keycloakBaseUrl',
  );
  @override
  late final GeneratedColumn<String> keycloakBaseUrl = GeneratedColumn<String>(
    'keycloak_base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _keycloakRealmMeta = const VerificationMeta(
    'keycloakRealm',
  );
  @override
  late final GeneratedColumn<String> keycloakRealm = GeneratedColumn<String>(
    'keycloak_realm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _keycloakClientIdMeta = const VerificationMeta(
    'keycloakClientId',
  );
  @override
  late final GeneratedColumn<String> keycloakClientId = GeneratedColumn<String>(
    'keycloak_client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _oidcAccessTokenMeta = const VerificationMeta(
    'oidcAccessToken',
  );
  @override
  late final GeneratedColumn<String> oidcAccessToken = GeneratedColumn<String>(
    'oidc_access_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _oidcRefreshTokenMeta = const VerificationMeta(
    'oidcRefreshToken',
  );
  @override
  late final GeneratedColumn<String> oidcRefreshToken = GeneratedColumn<String>(
    'oidc_refresh_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _oidcIdTokenMeta = const VerificationMeta(
    'oidcIdToken',
  );
  @override
  late final GeneratedColumn<String> oidcIdToken = GeneratedColumn<String>(
    'oidc_id_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _oidcExpiresAtEpochMsMeta =
      const VerificationMeta('oidcExpiresAtEpochMs');
  @override
  late final GeneratedColumn<int> oidcExpiresAtEpochMs = GeneratedColumn<int>(
    'oidc_expires_at_epoch_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _oidcScopeMeta = const VerificationMeta(
    'oidcScope',
  );
  @override
  late final GeneratedColumn<String> oidcScope = GeneratedColumn<String>(
    'oidc_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _oidcTokenTypeMeta = const VerificationMeta(
    'oidcTokenType',
  );
  @override
  late final GeneratedColumn<String> oidcTokenType = GeneratedColumn<String>(
    'oidc_token_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceName,
    serverAddress,
    keycloakBaseUrl,
    keycloakRealm,
    keycloakClientId,
    oidcAccessToken,
    oidcRefreshToken,
    oidcIdToken,
    oidcExpiresAtEpochMs,
    oidcScope,
    oidcTokenType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerProperty> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('service_name')) {
      context.handle(
        _serviceNameMeta,
        serviceName.isAcceptableOrUnknown(
          data['service_name']!,
          _serviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('server_address')) {
      context.handle(
        _serverAddressMeta,
        serverAddress.isAcceptableOrUnknown(
          data['server_address']!,
          _serverAddressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverAddressMeta);
    }
    if (data.containsKey('keycloak_base_url')) {
      context.handle(
        _keycloakBaseUrlMeta,
        keycloakBaseUrl.isAcceptableOrUnknown(
          data['keycloak_base_url']!,
          _keycloakBaseUrlMeta,
        ),
      );
    }
    if (data.containsKey('keycloak_realm')) {
      context.handle(
        _keycloakRealmMeta,
        keycloakRealm.isAcceptableOrUnknown(
          data['keycloak_realm']!,
          _keycloakRealmMeta,
        ),
      );
    }
    if (data.containsKey('keycloak_client_id')) {
      context.handle(
        _keycloakClientIdMeta,
        keycloakClientId.isAcceptableOrUnknown(
          data['keycloak_client_id']!,
          _keycloakClientIdMeta,
        ),
      );
    }
    if (data.containsKey('oidc_access_token')) {
      context.handle(
        _oidcAccessTokenMeta,
        oidcAccessToken.isAcceptableOrUnknown(
          data['oidc_access_token']!,
          _oidcAccessTokenMeta,
        ),
      );
    }
    if (data.containsKey('oidc_refresh_token')) {
      context.handle(
        _oidcRefreshTokenMeta,
        oidcRefreshToken.isAcceptableOrUnknown(
          data['oidc_refresh_token']!,
          _oidcRefreshTokenMeta,
        ),
      );
    }
    if (data.containsKey('oidc_id_token')) {
      context.handle(
        _oidcIdTokenMeta,
        oidcIdToken.isAcceptableOrUnknown(
          data['oidc_id_token']!,
          _oidcIdTokenMeta,
        ),
      );
    }
    if (data.containsKey('oidc_expires_at_epoch_ms')) {
      context.handle(
        _oidcExpiresAtEpochMsMeta,
        oidcExpiresAtEpochMs.isAcceptableOrUnknown(
          data['oidc_expires_at_epoch_ms']!,
          _oidcExpiresAtEpochMsMeta,
        ),
      );
    }
    if (data.containsKey('oidc_scope')) {
      context.handle(
        _oidcScopeMeta,
        oidcScope.isAcceptableOrUnknown(data['oidc_scope']!, _oidcScopeMeta),
      );
    }
    if (data.containsKey('oidc_token_type')) {
      context.handle(
        _oidcTokenTypeMeta,
        oidcTokenType.isAcceptableOrUnknown(
          data['oidc_token_type']!,
          _oidcTokenTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServerProperty map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerProperty(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_name'],
      )!,
      serverAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_address'],
      )!,
      keycloakBaseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keycloak_base_url'],
      )!,
      keycloakRealm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keycloak_realm'],
      )!,
      keycloakClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keycloak_client_id'],
      )!,
      oidcAccessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oidc_access_token'],
      )!,
      oidcRefreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oidc_refresh_token'],
      )!,
      oidcIdToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oidc_id_token'],
      )!,
      oidcExpiresAtEpochMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oidc_expires_at_epoch_ms'],
      )!,
      oidcScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oidc_scope'],
      )!,
      oidcTokenType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oidc_token_type'],
      )!,
    );
  }

  @override
  $ServerPropertiesTable createAlias(String alias) {
    return $ServerPropertiesTable(attachedDatabase, alias);
  }
}

class ServerProperty extends DataClass implements Insertable<ServerProperty> {
  final int id;
  final String serviceName;
  final String serverAddress;
  final String keycloakBaseUrl;
  final String keycloakRealm;
  final String keycloakClientId;
  final String oidcAccessToken;
  final String oidcRefreshToken;
  final String oidcIdToken;
  final int oidcExpiresAtEpochMs;
  final String oidcScope;
  final String oidcTokenType;
  const ServerProperty({
    required this.id,
    required this.serviceName,
    required this.serverAddress,
    required this.keycloakBaseUrl,
    required this.keycloakRealm,
    required this.keycloakClientId,
    required this.oidcAccessToken,
    required this.oidcRefreshToken,
    required this.oidcIdToken,
    required this.oidcExpiresAtEpochMs,
    required this.oidcScope,
    required this.oidcTokenType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_name'] = Variable<String>(serviceName);
    map['server_address'] = Variable<String>(serverAddress);
    map['keycloak_base_url'] = Variable<String>(keycloakBaseUrl);
    map['keycloak_realm'] = Variable<String>(keycloakRealm);
    map['keycloak_client_id'] = Variable<String>(keycloakClientId);
    map['oidc_access_token'] = Variable<String>(oidcAccessToken);
    map['oidc_refresh_token'] = Variable<String>(oidcRefreshToken);
    map['oidc_id_token'] = Variable<String>(oidcIdToken);
    map['oidc_expires_at_epoch_ms'] = Variable<int>(oidcExpiresAtEpochMs);
    map['oidc_scope'] = Variable<String>(oidcScope);
    map['oidc_token_type'] = Variable<String>(oidcTokenType);
    return map;
  }

  ServerPropertiesCompanion toCompanion(bool nullToAbsent) {
    return ServerPropertiesCompanion(
      id: Value(id),
      serviceName: Value(serviceName),
      serverAddress: Value(serverAddress),
      keycloakBaseUrl: Value(keycloakBaseUrl),
      keycloakRealm: Value(keycloakRealm),
      keycloakClientId: Value(keycloakClientId),
      oidcAccessToken: Value(oidcAccessToken),
      oidcRefreshToken: Value(oidcRefreshToken),
      oidcIdToken: Value(oidcIdToken),
      oidcExpiresAtEpochMs: Value(oidcExpiresAtEpochMs),
      oidcScope: Value(oidcScope),
      oidcTokenType: Value(oidcTokenType),
    );
  }

  factory ServerProperty.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerProperty(
      id: serializer.fromJson<int>(json['id']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      serverAddress: serializer.fromJson<String>(json['serverAddress']),
      keycloakBaseUrl: serializer.fromJson<String>(json['keycloakBaseUrl']),
      keycloakRealm: serializer.fromJson<String>(json['keycloakRealm']),
      keycloakClientId: serializer.fromJson<String>(json['keycloakClientId']),
      oidcAccessToken: serializer.fromJson<String>(json['oidcAccessToken']),
      oidcRefreshToken: serializer.fromJson<String>(json['oidcRefreshToken']),
      oidcIdToken: serializer.fromJson<String>(json['oidcIdToken']),
      oidcExpiresAtEpochMs: serializer.fromJson<int>(
        json['oidcExpiresAtEpochMs'],
      ),
      oidcScope: serializer.fromJson<String>(json['oidcScope']),
      oidcTokenType: serializer.fromJson<String>(json['oidcTokenType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceName': serializer.toJson<String>(serviceName),
      'serverAddress': serializer.toJson<String>(serverAddress),
      'keycloakBaseUrl': serializer.toJson<String>(keycloakBaseUrl),
      'keycloakRealm': serializer.toJson<String>(keycloakRealm),
      'keycloakClientId': serializer.toJson<String>(keycloakClientId),
      'oidcAccessToken': serializer.toJson<String>(oidcAccessToken),
      'oidcRefreshToken': serializer.toJson<String>(oidcRefreshToken),
      'oidcIdToken': serializer.toJson<String>(oidcIdToken),
      'oidcExpiresAtEpochMs': serializer.toJson<int>(oidcExpiresAtEpochMs),
      'oidcScope': serializer.toJson<String>(oidcScope),
      'oidcTokenType': serializer.toJson<String>(oidcTokenType),
    };
  }

  ServerProperty copyWith({
    int? id,
    String? serviceName,
    String? serverAddress,
    String? keycloakBaseUrl,
    String? keycloakRealm,
    String? keycloakClientId,
    String? oidcAccessToken,
    String? oidcRefreshToken,
    String? oidcIdToken,
    int? oidcExpiresAtEpochMs,
    String? oidcScope,
    String? oidcTokenType,
  }) => ServerProperty(
    id: id ?? this.id,
    serviceName: serviceName ?? this.serviceName,
    serverAddress: serverAddress ?? this.serverAddress,
    keycloakBaseUrl: keycloakBaseUrl ?? this.keycloakBaseUrl,
    keycloakRealm: keycloakRealm ?? this.keycloakRealm,
    keycloakClientId: keycloakClientId ?? this.keycloakClientId,
    oidcAccessToken: oidcAccessToken ?? this.oidcAccessToken,
    oidcRefreshToken: oidcRefreshToken ?? this.oidcRefreshToken,
    oidcIdToken: oidcIdToken ?? this.oidcIdToken,
    oidcExpiresAtEpochMs: oidcExpiresAtEpochMs ?? this.oidcExpiresAtEpochMs,
    oidcScope: oidcScope ?? this.oidcScope,
    oidcTokenType: oidcTokenType ?? this.oidcTokenType,
  );
  ServerProperty copyWithCompanion(ServerPropertiesCompanion data) {
    return ServerProperty(
      id: data.id.present ? data.id.value : this.id,
      serviceName: data.serviceName.present
          ? data.serviceName.value
          : this.serviceName,
      serverAddress: data.serverAddress.present
          ? data.serverAddress.value
          : this.serverAddress,
      keycloakBaseUrl: data.keycloakBaseUrl.present
          ? data.keycloakBaseUrl.value
          : this.keycloakBaseUrl,
      keycloakRealm: data.keycloakRealm.present
          ? data.keycloakRealm.value
          : this.keycloakRealm,
      keycloakClientId: data.keycloakClientId.present
          ? data.keycloakClientId.value
          : this.keycloakClientId,
      oidcAccessToken: data.oidcAccessToken.present
          ? data.oidcAccessToken.value
          : this.oidcAccessToken,
      oidcRefreshToken: data.oidcRefreshToken.present
          ? data.oidcRefreshToken.value
          : this.oidcRefreshToken,
      oidcIdToken: data.oidcIdToken.present
          ? data.oidcIdToken.value
          : this.oidcIdToken,
      oidcExpiresAtEpochMs: data.oidcExpiresAtEpochMs.present
          ? data.oidcExpiresAtEpochMs.value
          : this.oidcExpiresAtEpochMs,
      oidcScope: data.oidcScope.present ? data.oidcScope.value : this.oidcScope,
      oidcTokenType: data.oidcTokenType.present
          ? data.oidcTokenType.value
          : this.oidcTokenType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerProperty(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('serverAddress: $serverAddress, ')
          ..write('keycloakBaseUrl: $keycloakBaseUrl, ')
          ..write('keycloakRealm: $keycloakRealm, ')
          ..write('keycloakClientId: $keycloakClientId, ')
          ..write('oidcAccessToken: $oidcAccessToken, ')
          ..write('oidcRefreshToken: $oidcRefreshToken, ')
          ..write('oidcIdToken: $oidcIdToken, ')
          ..write('oidcExpiresAtEpochMs: $oidcExpiresAtEpochMs, ')
          ..write('oidcScope: $oidcScope, ')
          ..write('oidcTokenType: $oidcTokenType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serviceName,
    serverAddress,
    keycloakBaseUrl,
    keycloakRealm,
    keycloakClientId,
    oidcAccessToken,
    oidcRefreshToken,
    oidcIdToken,
    oidcExpiresAtEpochMs,
    oidcScope,
    oidcTokenType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerProperty &&
          other.id == this.id &&
          other.serviceName == this.serviceName &&
          other.serverAddress == this.serverAddress &&
          other.keycloakBaseUrl == this.keycloakBaseUrl &&
          other.keycloakRealm == this.keycloakRealm &&
          other.keycloakClientId == this.keycloakClientId &&
          other.oidcAccessToken == this.oidcAccessToken &&
          other.oidcRefreshToken == this.oidcRefreshToken &&
          other.oidcIdToken == this.oidcIdToken &&
          other.oidcExpiresAtEpochMs == this.oidcExpiresAtEpochMs &&
          other.oidcScope == this.oidcScope &&
          other.oidcTokenType == this.oidcTokenType);
}

class ServerPropertiesCompanion extends UpdateCompanion<ServerProperty> {
  final Value<int> id;
  final Value<String> serviceName;
  final Value<String> serverAddress;
  final Value<String> keycloakBaseUrl;
  final Value<String> keycloakRealm;
  final Value<String> keycloakClientId;
  final Value<String> oidcAccessToken;
  final Value<String> oidcRefreshToken;
  final Value<String> oidcIdToken;
  final Value<int> oidcExpiresAtEpochMs;
  final Value<String> oidcScope;
  final Value<String> oidcTokenType;
  const ServerPropertiesCompanion({
    this.id = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.serverAddress = const Value.absent(),
    this.keycloakBaseUrl = const Value.absent(),
    this.keycloakRealm = const Value.absent(),
    this.keycloakClientId = const Value.absent(),
    this.oidcAccessToken = const Value.absent(),
    this.oidcRefreshToken = const Value.absent(),
    this.oidcIdToken = const Value.absent(),
    this.oidcExpiresAtEpochMs = const Value.absent(),
    this.oidcScope = const Value.absent(),
    this.oidcTokenType = const Value.absent(),
  });
  ServerPropertiesCompanion.insert({
    this.id = const Value.absent(),
    required String serviceName,
    required String serverAddress,
    this.keycloakBaseUrl = const Value.absent(),
    this.keycloakRealm = const Value.absent(),
    this.keycloakClientId = const Value.absent(),
    this.oidcAccessToken = const Value.absent(),
    this.oidcRefreshToken = const Value.absent(),
    this.oidcIdToken = const Value.absent(),
    this.oidcExpiresAtEpochMs = const Value.absent(),
    this.oidcScope = const Value.absent(),
    this.oidcTokenType = const Value.absent(),
  }) : serviceName = Value(serviceName),
       serverAddress = Value(serverAddress);
  static Insertable<ServerProperty> custom({
    Expression<int>? id,
    Expression<String>? serviceName,
    Expression<String>? serverAddress,
    Expression<String>? keycloakBaseUrl,
    Expression<String>? keycloakRealm,
    Expression<String>? keycloakClientId,
    Expression<String>? oidcAccessToken,
    Expression<String>? oidcRefreshToken,
    Expression<String>? oidcIdToken,
    Expression<int>? oidcExpiresAtEpochMs,
    Expression<String>? oidcScope,
    Expression<String>? oidcTokenType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceName != null) 'service_name': serviceName,
      if (serverAddress != null) 'server_address': serverAddress,
      if (keycloakBaseUrl != null) 'keycloak_base_url': keycloakBaseUrl,
      if (keycloakRealm != null) 'keycloak_realm': keycloakRealm,
      if (keycloakClientId != null) 'keycloak_client_id': keycloakClientId,
      if (oidcAccessToken != null) 'oidc_access_token': oidcAccessToken,
      if (oidcRefreshToken != null) 'oidc_refresh_token': oidcRefreshToken,
      if (oidcIdToken != null) 'oidc_id_token': oidcIdToken,
      if (oidcExpiresAtEpochMs != null)
        'oidc_expires_at_epoch_ms': oidcExpiresAtEpochMs,
      if (oidcScope != null) 'oidc_scope': oidcScope,
      if (oidcTokenType != null) 'oidc_token_type': oidcTokenType,
    });
  }

  ServerPropertiesCompanion copyWith({
    Value<int>? id,
    Value<String>? serviceName,
    Value<String>? serverAddress,
    Value<String>? keycloakBaseUrl,
    Value<String>? keycloakRealm,
    Value<String>? keycloakClientId,
    Value<String>? oidcAccessToken,
    Value<String>? oidcRefreshToken,
    Value<String>? oidcIdToken,
    Value<int>? oidcExpiresAtEpochMs,
    Value<String>? oidcScope,
    Value<String>? oidcTokenType,
  }) {
    return ServerPropertiesCompanion(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      serverAddress: serverAddress ?? this.serverAddress,
      keycloakBaseUrl: keycloakBaseUrl ?? this.keycloakBaseUrl,
      keycloakRealm: keycloakRealm ?? this.keycloakRealm,
      keycloakClientId: keycloakClientId ?? this.keycloakClientId,
      oidcAccessToken: oidcAccessToken ?? this.oidcAccessToken,
      oidcRefreshToken: oidcRefreshToken ?? this.oidcRefreshToken,
      oidcIdToken: oidcIdToken ?? this.oidcIdToken,
      oidcExpiresAtEpochMs: oidcExpiresAtEpochMs ?? this.oidcExpiresAtEpochMs,
      oidcScope: oidcScope ?? this.oidcScope,
      oidcTokenType: oidcTokenType ?? this.oidcTokenType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (serverAddress.present) {
      map['server_address'] = Variable<String>(serverAddress.value);
    }
    if (keycloakBaseUrl.present) {
      map['keycloak_base_url'] = Variable<String>(keycloakBaseUrl.value);
    }
    if (keycloakRealm.present) {
      map['keycloak_realm'] = Variable<String>(keycloakRealm.value);
    }
    if (keycloakClientId.present) {
      map['keycloak_client_id'] = Variable<String>(keycloakClientId.value);
    }
    if (oidcAccessToken.present) {
      map['oidc_access_token'] = Variable<String>(oidcAccessToken.value);
    }
    if (oidcRefreshToken.present) {
      map['oidc_refresh_token'] = Variable<String>(oidcRefreshToken.value);
    }
    if (oidcIdToken.present) {
      map['oidc_id_token'] = Variable<String>(oidcIdToken.value);
    }
    if (oidcExpiresAtEpochMs.present) {
      map['oidc_expires_at_epoch_ms'] = Variable<int>(
        oidcExpiresAtEpochMs.value,
      );
    }
    if (oidcScope.present) {
      map['oidc_scope'] = Variable<String>(oidcScope.value);
    }
    if (oidcTokenType.present) {
      map['oidc_token_type'] = Variable<String>(oidcTokenType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerPropertiesCompanion(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('serverAddress: $serverAddress, ')
          ..write('keycloakBaseUrl: $keycloakBaseUrl, ')
          ..write('keycloakRealm: $keycloakRealm, ')
          ..write('keycloakClientId: $keycloakClientId, ')
          ..write('oidcAccessToken: $oidcAccessToken, ')
          ..write('oidcRefreshToken: $oidcRefreshToken, ')
          ..write('oidcIdToken: $oidcIdToken, ')
          ..write('oidcExpiresAtEpochMs: $oidcExpiresAtEpochMs, ')
          ..write('oidcScope: $oidcScope, ')
          ..write('oidcTokenType: $oidcTokenType')
          ..write(')'))
        .toString();
  }
}

class $CurrencyExchangeRatesTable extends CurrencyExchangeRates
    with TableInfo<$CurrencyExchangeRatesTable, CurrencyExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrencyExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<int> remoteId = GeneratedColumn<int>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flagImageIdMeta = const VerificationMeta(
    'flagImageId',
  );
  @override
  late final GeneratedColumn<int> flagImageId = GeneratedColumn<int>(
    'flag_image_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flagImagePathMeta = const VerificationMeta(
    'flagImagePath',
  );
  @override
  late final GeneratedColumn<String> flagImagePath = GeneratedColumn<String>(
    'flag_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryNameMeta = const VerificationMeta(
    'countryName',
  );
  @override
  late final GeneratedColumn<String> countryName = GeneratedColumn<String>(
    'country_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buyMeta = const VerificationMeta('buy');
  @override
  late final GeneratedColumn<int> buy = GeneratedColumn<int>(
    'buy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellMeta = const VerificationMeta('sell');
  @override
  late final GeneratedColumn<int> sell = GeneratedColumn<int>(
    'sell',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteId,
    flagImageId,
    flagImagePath,
    countryName,
    currencyCode,
    buy,
    sell,
    position,
    tag,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currency_exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurrencyExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('flag_image_id')) {
      context.handle(
        _flagImageIdMeta,
        flagImageId.isAcceptableOrUnknown(
          data['flag_image_id']!,
          _flagImageIdMeta,
        ),
      );
    }
    if (data.containsKey('flag_image_path')) {
      context.handle(
        _flagImagePathMeta,
        flagImagePath.isAcceptableOrUnknown(
          data['flag_image_path']!,
          _flagImagePathMeta,
        ),
      );
    }
    if (data.containsKey('country_name')) {
      context.handle(
        _countryNameMeta,
        countryName.isAcceptableOrUnknown(
          data['country_name']!,
          _countryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_countryNameMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('buy')) {
      context.handle(
        _buyMeta,
        buy.isAcceptableOrUnknown(data['buy']!, _buyMeta),
      );
    } else if (isInserting) {
      context.missing(_buyMeta);
    }
    if (data.containsKey('sell')) {
      context.handle(
        _sellMeta,
        sell.isAcceptableOrUnknown(data['sell']!, _sellMeta),
      );
    } else if (isInserting) {
      context.missing(_sellMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CurrencyExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrencyExchangeRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_id'],
      )!,
      flagImageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flag_image_id'],
      ),
      flagImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flag_image_path'],
      ),
      countryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_name'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      buy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buy'],
      )!,
      sell: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $CurrencyExchangeRatesTable createAlias(String alias) {
    return $CurrencyExchangeRatesTable(attachedDatabase, alias);
  }
}

class CurrencyExchangeRate extends DataClass
    implements Insertable<CurrencyExchangeRate> {
  final int id;
  final int remoteId;
  final int? flagImageId;
  final String? flagImagePath;
  final String countryName;
  final String currencyCode;
  final int buy;
  final int sell;
  final int position;
  final String tag;
  const CurrencyExchangeRate({
    required this.id,
    required this.remoteId,
    this.flagImageId,
    this.flagImagePath,
    required this.countryName,
    required this.currencyCode,
    required this.buy,
    required this.sell,
    required this.position,
    required this.tag,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['remote_id'] = Variable<int>(remoteId);
    if (!nullToAbsent || flagImageId != null) {
      map['flag_image_id'] = Variable<int>(flagImageId);
    }
    if (!nullToAbsent || flagImagePath != null) {
      map['flag_image_path'] = Variable<String>(flagImagePath);
    }
    map['country_name'] = Variable<String>(countryName);
    map['currency_code'] = Variable<String>(currencyCode);
    map['buy'] = Variable<int>(buy);
    map['sell'] = Variable<int>(sell);
    map['position'] = Variable<int>(position);
    map['tag'] = Variable<String>(tag);
    return map;
  }

  CurrencyExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return CurrencyExchangeRatesCompanion(
      id: Value(id),
      remoteId: Value(remoteId),
      flagImageId: flagImageId == null && nullToAbsent
          ? const Value.absent()
          : Value(flagImageId),
      flagImagePath: flagImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(flagImagePath),
      countryName: Value(countryName),
      currencyCode: Value(currencyCode),
      buy: Value(buy),
      sell: Value(sell),
      position: Value(position),
      tag: Value(tag),
    );
  }

  factory CurrencyExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrencyExchangeRate(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<int>(json['remoteId']),
      flagImageId: serializer.fromJson<int?>(json['flagImageId']),
      flagImagePath: serializer.fromJson<String?>(json['flagImagePath']),
      countryName: serializer.fromJson<String>(json['countryName']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      buy: serializer.fromJson<int>(json['buy']),
      sell: serializer.fromJson<int>(json['sell']),
      position: serializer.fromJson<int>(json['position']),
      tag: serializer.fromJson<String>(json['tag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<int>(remoteId),
      'flagImageId': serializer.toJson<int?>(flagImageId),
      'flagImagePath': serializer.toJson<String?>(flagImagePath),
      'countryName': serializer.toJson<String>(countryName),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'buy': serializer.toJson<int>(buy),
      'sell': serializer.toJson<int>(sell),
      'position': serializer.toJson<int>(position),
      'tag': serializer.toJson<String>(tag),
    };
  }

  CurrencyExchangeRate copyWith({
    int? id,
    int? remoteId,
    Value<int?> flagImageId = const Value.absent(),
    Value<String?> flagImagePath = const Value.absent(),
    String? countryName,
    String? currencyCode,
    int? buy,
    int? sell,
    int? position,
    String? tag,
  }) => CurrencyExchangeRate(
    id: id ?? this.id,
    remoteId: remoteId ?? this.remoteId,
    flagImageId: flagImageId.present ? flagImageId.value : this.flagImageId,
    flagImagePath: flagImagePath.present
        ? flagImagePath.value
        : this.flagImagePath,
    countryName: countryName ?? this.countryName,
    currencyCode: currencyCode ?? this.currencyCode,
    buy: buy ?? this.buy,
    sell: sell ?? this.sell,
    position: position ?? this.position,
    tag: tag ?? this.tag,
  );
  CurrencyExchangeRate copyWithCompanion(CurrencyExchangeRatesCompanion data) {
    return CurrencyExchangeRate(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      flagImageId: data.flagImageId.present
          ? data.flagImageId.value
          : this.flagImageId,
      flagImagePath: data.flagImagePath.present
          ? data.flagImagePath.value
          : this.flagImagePath,
      countryName: data.countryName.present
          ? data.countryName.value
          : this.countryName,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      buy: data.buy.present ? data.buy.value : this.buy,
      sell: data.sell.present ? data.sell.value : this.sell,
      position: data.position.present ? data.position.value : this.position,
      tag: data.tag.present ? data.tag.value : this.tag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyExchangeRate(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('flagImageId: $flagImageId, ')
          ..write('flagImagePath: $flagImagePath, ')
          ..write('countryName: $countryName, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('buy: $buy, ')
          ..write('sell: $sell, ')
          ..write('position: $position, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteId,
    flagImageId,
    flagImagePath,
    countryName,
    currencyCode,
    buy,
    sell,
    position,
    tag,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrencyExchangeRate &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.flagImageId == this.flagImageId &&
          other.flagImagePath == this.flagImagePath &&
          other.countryName == this.countryName &&
          other.currencyCode == this.currencyCode &&
          other.buy == this.buy &&
          other.sell == this.sell &&
          other.position == this.position &&
          other.tag == this.tag);
}

class CurrencyExchangeRatesCompanion
    extends UpdateCompanion<CurrencyExchangeRate> {
  final Value<int> id;
  final Value<int> remoteId;
  final Value<int?> flagImageId;
  final Value<String?> flagImagePath;
  final Value<String> countryName;
  final Value<String> currencyCode;
  final Value<int> buy;
  final Value<int> sell;
  final Value<int> position;
  final Value<String> tag;
  const CurrencyExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.flagImageId = const Value.absent(),
    this.flagImagePath = const Value.absent(),
    this.countryName = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.buy = const Value.absent(),
    this.sell = const Value.absent(),
    this.position = const Value.absent(),
    this.tag = const Value.absent(),
  });
  CurrencyExchangeRatesCompanion.insert({
    this.id = const Value.absent(),
    required int remoteId,
    this.flagImageId = const Value.absent(),
    this.flagImagePath = const Value.absent(),
    required String countryName,
    required String currencyCode,
    required int buy,
    required int sell,
    required int position,
    required String tag,
  }) : remoteId = Value(remoteId),
       countryName = Value(countryName),
       currencyCode = Value(currencyCode),
       buy = Value(buy),
       sell = Value(sell),
       position = Value(position),
       tag = Value(tag);
  static Insertable<CurrencyExchangeRate> custom({
    Expression<int>? id,
    Expression<int>? remoteId,
    Expression<int>? flagImageId,
    Expression<String>? flagImagePath,
    Expression<String>? countryName,
    Expression<String>? currencyCode,
    Expression<int>? buy,
    Expression<int>? sell,
    Expression<int>? position,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (flagImageId != null) 'flag_image_id': flagImageId,
      if (flagImagePath != null) 'flag_image_path': flagImagePath,
      if (countryName != null) 'country_name': countryName,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (buy != null) 'buy': buy,
      if (sell != null) 'sell': sell,
      if (position != null) 'position': position,
      if (tag != null) 'tag': tag,
    });
  }

  CurrencyExchangeRatesCompanion copyWith({
    Value<int>? id,
    Value<int>? remoteId,
    Value<int?>? flagImageId,
    Value<String?>? flagImagePath,
    Value<String>? countryName,
    Value<String>? currencyCode,
    Value<int>? buy,
    Value<int>? sell,
    Value<int>? position,
    Value<String>? tag,
  }) {
    return CurrencyExchangeRatesCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      flagImageId: flagImageId ?? this.flagImageId,
      flagImagePath: flagImagePath ?? this.flagImagePath,
      countryName: countryName ?? this.countryName,
      currencyCode: currencyCode ?? this.currencyCode,
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
      position: position ?? this.position,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<int>(remoteId.value);
    }
    if (flagImageId.present) {
      map['flag_image_id'] = Variable<int>(flagImageId.value);
    }
    if (flagImagePath.present) {
      map['flag_image_path'] = Variable<String>(flagImagePath.value);
    }
    if (countryName.present) {
      map['country_name'] = Variable<String>(countryName.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (buy.present) {
      map['buy'] = Variable<int>(buy.value);
    }
    if (sell.present) {
      map['sell'] = Variable<int>(sell.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('flagImageId: $flagImageId, ')
          ..write('flagImagePath: $flagImagePath, ')
          ..write('countryName: $countryName, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('buy: $buy, ')
          ..write('sell: $sell, ')
          ..write('position: $position, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaTable media = $MediaTable(this);
  late final $ServerPropertiesTable serverProperties = $ServerPropertiesTable(
    this,
  );
  late final $CurrencyExchangeRatesTable currencyExchangeRates =
      $CurrencyExchangeRatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    media,
    serverProperties,
    currencyExchangeRates,
  ];
}

typedef $$MediaTableCreateCompanionBuilder =
    MediaCompanion Function({
      Value<int> id,
      required int remoteId,
      required String path,
      required int position,
      required String contentType,
      required String mimeType,
      required String tag,
    });
typedef $$MediaTableUpdateCompanionBuilder =
    MediaCompanion Function({
      Value<int> id,
      Value<int> remoteId,
      Value<String> path,
      Value<int> position,
      Value<String> contentType,
      Value<String> mimeType,
      Value<String> tag,
    });

class $$MediaTableFilterComposer extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTable> {
  $$MediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$MediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaTable,
          MediaData,
          $$MediaTableFilterComposer,
          $$MediaTableOrderingComposer,
          $$MediaTableAnnotationComposer,
          $$MediaTableCreateCompanionBuilder,
          $$MediaTableUpdateCompanionBuilder,
          (MediaData, BaseReferences<_$AppDatabase, $MediaTable, MediaData>),
          MediaData,
          PrefetchHooks Function()
        > {
  $$MediaTableTableManager(_$AppDatabase db, $MediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<String> tag = const Value.absent(),
              }) => MediaCompanion(
                id: id,
                remoteId: remoteId,
                path: path,
                position: position,
                contentType: contentType,
                mimeType: mimeType,
                tag: tag,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int remoteId,
                required String path,
                required int position,
                required String contentType,
                required String mimeType,
                required String tag,
              }) => MediaCompanion.insert(
                id: id,
                remoteId: remoteId,
                path: path,
                position: position,
                contentType: contentType,
                mimeType: mimeType,
                tag: tag,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaTable,
      MediaData,
      $$MediaTableFilterComposer,
      $$MediaTableOrderingComposer,
      $$MediaTableAnnotationComposer,
      $$MediaTableCreateCompanionBuilder,
      $$MediaTableUpdateCompanionBuilder,
      (MediaData, BaseReferences<_$AppDatabase, $MediaTable, MediaData>),
      MediaData,
      PrefetchHooks Function()
    >;
typedef $$ServerPropertiesTableCreateCompanionBuilder =
    ServerPropertiesCompanion Function({
      Value<int> id,
      required String serviceName,
      required String serverAddress,
      Value<String> keycloakBaseUrl,
      Value<String> keycloakRealm,
      Value<String> keycloakClientId,
      Value<String> oidcAccessToken,
      Value<String> oidcRefreshToken,
      Value<String> oidcIdToken,
      Value<int> oidcExpiresAtEpochMs,
      Value<String> oidcScope,
      Value<String> oidcTokenType,
    });
typedef $$ServerPropertiesTableUpdateCompanionBuilder =
    ServerPropertiesCompanion Function({
      Value<int> id,
      Value<String> serviceName,
      Value<String> serverAddress,
      Value<String> keycloakBaseUrl,
      Value<String> keycloakRealm,
      Value<String> keycloakClientId,
      Value<String> oidcAccessToken,
      Value<String> oidcRefreshToken,
      Value<String> oidcIdToken,
      Value<int> oidcExpiresAtEpochMs,
      Value<String> oidcScope,
      Value<String> oidcTokenType,
    });

class $$ServerPropertiesTableFilterComposer
    extends Composer<_$AppDatabase, $ServerPropertiesTable> {
  $$ServerPropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverAddress => $composableBuilder(
    column: $table.serverAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keycloakBaseUrl => $composableBuilder(
    column: $table.keycloakBaseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keycloakRealm => $composableBuilder(
    column: $table.keycloakRealm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keycloakClientId => $composableBuilder(
    column: $table.keycloakClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oidcAccessToken => $composableBuilder(
    column: $table.oidcAccessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oidcRefreshToken => $composableBuilder(
    column: $table.oidcRefreshToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oidcIdToken => $composableBuilder(
    column: $table.oidcIdToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oidcExpiresAtEpochMs => $composableBuilder(
    column: $table.oidcExpiresAtEpochMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oidcScope => $composableBuilder(
    column: $table.oidcScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oidcTokenType => $composableBuilder(
    column: $table.oidcTokenType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServerPropertiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServerPropertiesTable> {
  $$ServerPropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverAddress => $composableBuilder(
    column: $table.serverAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keycloakBaseUrl => $composableBuilder(
    column: $table.keycloakBaseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keycloakRealm => $composableBuilder(
    column: $table.keycloakRealm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keycloakClientId => $composableBuilder(
    column: $table.keycloakClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oidcAccessToken => $composableBuilder(
    column: $table.oidcAccessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oidcRefreshToken => $composableBuilder(
    column: $table.oidcRefreshToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oidcIdToken => $composableBuilder(
    column: $table.oidcIdToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oidcExpiresAtEpochMs => $composableBuilder(
    column: $table.oidcExpiresAtEpochMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oidcScope => $composableBuilder(
    column: $table.oidcScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oidcTokenType => $composableBuilder(
    column: $table.oidcTokenType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerPropertiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServerPropertiesTable> {
  $$ServerPropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverAddress => $composableBuilder(
    column: $table.serverAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keycloakBaseUrl => $composableBuilder(
    column: $table.keycloakBaseUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keycloakRealm => $composableBuilder(
    column: $table.keycloakRealm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keycloakClientId => $composableBuilder(
    column: $table.keycloakClientId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oidcAccessToken => $composableBuilder(
    column: $table.oidcAccessToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oidcRefreshToken => $composableBuilder(
    column: $table.oidcRefreshToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oidcIdToken => $composableBuilder(
    column: $table.oidcIdToken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oidcExpiresAtEpochMs => $composableBuilder(
    column: $table.oidcExpiresAtEpochMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oidcScope =>
      $composableBuilder(column: $table.oidcScope, builder: (column) => column);

  GeneratedColumn<String> get oidcTokenType => $composableBuilder(
    column: $table.oidcTokenType,
    builder: (column) => column,
  );
}

class $$ServerPropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServerPropertiesTable,
          ServerProperty,
          $$ServerPropertiesTableFilterComposer,
          $$ServerPropertiesTableOrderingComposer,
          $$ServerPropertiesTableAnnotationComposer,
          $$ServerPropertiesTableCreateCompanionBuilder,
          $$ServerPropertiesTableUpdateCompanionBuilder,
          (
            ServerProperty,
            BaseReferences<
              _$AppDatabase,
              $ServerPropertiesTable,
              ServerProperty
            >,
          ),
          ServerProperty,
          PrefetchHooks Function()
        > {
  $$ServerPropertiesTableTableManager(
    _$AppDatabase db,
    $ServerPropertiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerPropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerPropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerPropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> serviceName = const Value.absent(),
                Value<String> serverAddress = const Value.absent(),
                Value<String> keycloakBaseUrl = const Value.absent(),
                Value<String> keycloakRealm = const Value.absent(),
                Value<String> keycloakClientId = const Value.absent(),
                Value<String> oidcAccessToken = const Value.absent(),
                Value<String> oidcRefreshToken = const Value.absent(),
                Value<String> oidcIdToken = const Value.absent(),
                Value<int> oidcExpiresAtEpochMs = const Value.absent(),
                Value<String> oidcScope = const Value.absent(),
                Value<String> oidcTokenType = const Value.absent(),
              }) => ServerPropertiesCompanion(
                id: id,
                serviceName: serviceName,
                serverAddress: serverAddress,
                keycloakBaseUrl: keycloakBaseUrl,
                keycloakRealm: keycloakRealm,
                keycloakClientId: keycloakClientId,
                oidcAccessToken: oidcAccessToken,
                oidcRefreshToken: oidcRefreshToken,
                oidcIdToken: oidcIdToken,
                oidcExpiresAtEpochMs: oidcExpiresAtEpochMs,
                oidcScope: oidcScope,
                oidcTokenType: oidcTokenType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String serviceName,
                required String serverAddress,
                Value<String> keycloakBaseUrl = const Value.absent(),
                Value<String> keycloakRealm = const Value.absent(),
                Value<String> keycloakClientId = const Value.absent(),
                Value<String> oidcAccessToken = const Value.absent(),
                Value<String> oidcRefreshToken = const Value.absent(),
                Value<String> oidcIdToken = const Value.absent(),
                Value<int> oidcExpiresAtEpochMs = const Value.absent(),
                Value<String> oidcScope = const Value.absent(),
                Value<String> oidcTokenType = const Value.absent(),
              }) => ServerPropertiesCompanion.insert(
                id: id,
                serviceName: serviceName,
                serverAddress: serverAddress,
                keycloakBaseUrl: keycloakBaseUrl,
                keycloakRealm: keycloakRealm,
                keycloakClientId: keycloakClientId,
                oidcAccessToken: oidcAccessToken,
                oidcRefreshToken: oidcRefreshToken,
                oidcIdToken: oidcIdToken,
                oidcExpiresAtEpochMs: oidcExpiresAtEpochMs,
                oidcScope: oidcScope,
                oidcTokenType: oidcTokenType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerPropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServerPropertiesTable,
      ServerProperty,
      $$ServerPropertiesTableFilterComposer,
      $$ServerPropertiesTableOrderingComposer,
      $$ServerPropertiesTableAnnotationComposer,
      $$ServerPropertiesTableCreateCompanionBuilder,
      $$ServerPropertiesTableUpdateCompanionBuilder,
      (
        ServerProperty,
        BaseReferences<_$AppDatabase, $ServerPropertiesTable, ServerProperty>,
      ),
      ServerProperty,
      PrefetchHooks Function()
    >;
typedef $$CurrencyExchangeRatesTableCreateCompanionBuilder =
    CurrencyExchangeRatesCompanion Function({
      Value<int> id,
      required int remoteId,
      Value<int?> flagImageId,
      Value<String?> flagImagePath,
      required String countryName,
      required String currencyCode,
      required int buy,
      required int sell,
      required int position,
      required String tag,
    });
typedef $$CurrencyExchangeRatesTableUpdateCompanionBuilder =
    CurrencyExchangeRatesCompanion Function({
      Value<int> id,
      Value<int> remoteId,
      Value<int?> flagImageId,
      Value<String?> flagImagePath,
      Value<String> countryName,
      Value<String> currencyCode,
      Value<int> buy,
      Value<int> sell,
      Value<int> position,
      Value<String> tag,
    });

class $$CurrencyExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrencyExchangeRatesTable> {
  $$CurrencyExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flagImageId => $composableBuilder(
    column: $table.flagImageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flagImagePath => $composableBuilder(
    column: $table.flagImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countryName => $composableBuilder(
    column: $table.countryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buy => $composableBuilder(
    column: $table.buy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sell => $composableBuilder(
    column: $table.sell,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrencyExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrencyExchangeRatesTable> {
  $$CurrencyExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flagImageId => $composableBuilder(
    column: $table.flagImageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flagImagePath => $composableBuilder(
    column: $table.flagImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countryName => $composableBuilder(
    column: $table.countryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buy => $composableBuilder(
    column: $table.buy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sell => $composableBuilder(
    column: $table.sell,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrencyExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrencyExchangeRatesTable> {
  $$CurrencyExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<int> get flagImageId => $composableBuilder(
    column: $table.flagImageId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flagImagePath => $composableBuilder(
    column: $table.flagImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countryName => $composableBuilder(
    column: $table.countryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get buy =>
      $composableBuilder(column: $table.buy, builder: (column) => column);

  GeneratedColumn<int> get sell =>
      $composableBuilder(column: $table.sell, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$CurrencyExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrencyExchangeRatesTable,
          CurrencyExchangeRate,
          $$CurrencyExchangeRatesTableFilterComposer,
          $$CurrencyExchangeRatesTableOrderingComposer,
          $$CurrencyExchangeRatesTableAnnotationComposer,
          $$CurrencyExchangeRatesTableCreateCompanionBuilder,
          $$CurrencyExchangeRatesTableUpdateCompanionBuilder,
          (
            CurrencyExchangeRate,
            BaseReferences<
              _$AppDatabase,
              $CurrencyExchangeRatesTable,
              CurrencyExchangeRate
            >,
          ),
          CurrencyExchangeRate,
          PrefetchHooks Function()
        > {
  $$CurrencyExchangeRatesTableTableManager(
    _$AppDatabase db,
    $CurrencyExchangeRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrencyExchangeRatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CurrencyExchangeRatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CurrencyExchangeRatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> remoteId = const Value.absent(),
                Value<int?> flagImageId = const Value.absent(),
                Value<String?> flagImagePath = const Value.absent(),
                Value<String> countryName = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> buy = const Value.absent(),
                Value<int> sell = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> tag = const Value.absent(),
              }) => CurrencyExchangeRatesCompanion(
                id: id,
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
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int remoteId,
                Value<int?> flagImageId = const Value.absent(),
                Value<String?> flagImagePath = const Value.absent(),
                required String countryName,
                required String currencyCode,
                required int buy,
                required int sell,
                required int position,
                required String tag,
              }) => CurrencyExchangeRatesCompanion.insert(
                id: id,
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
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurrencyExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrencyExchangeRatesTable,
      CurrencyExchangeRate,
      $$CurrencyExchangeRatesTableFilterComposer,
      $$CurrencyExchangeRatesTableOrderingComposer,
      $$CurrencyExchangeRatesTableAnnotationComposer,
      $$CurrencyExchangeRatesTableCreateCompanionBuilder,
      $$CurrencyExchangeRatesTableUpdateCompanionBuilder,
      (
        CurrencyExchangeRate,
        BaseReferences<
          _$AppDatabase,
          $CurrencyExchangeRatesTable,
          CurrencyExchangeRate
        >,
      ),
      CurrencyExchangeRate,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$ServerPropertiesTableTableManager get serverProperties =>
      $$ServerPropertiesTableTableManager(_db, _db.serverProperties);
  $$CurrencyExchangeRatesTableTableManager get currencyExchangeRates =>
      $$CurrencyExchangeRatesTableTableManager(_db, _db.currencyExchangeRates);
}
