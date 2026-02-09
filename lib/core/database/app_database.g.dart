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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cookieMeta = const VerificationMeta('cookie');
  @override
  late final GeneratedColumn<String> cookie = GeneratedColumn<String>(
    'cookie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceName,
    serverAddress,
    username,
    password,
    cookie,
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
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('cookie')) {
      context.handle(
        _cookieMeta,
        cookie.isAcceptableOrUnknown(data['cookie']!, _cookieMeta),
      );
    } else if (isInserting) {
      context.missing(_cookieMeta);
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
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      cookie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cookie'],
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
  final String username;
  final String password;
  final String cookie;
  const ServerProperty({
    required this.id,
    required this.serviceName,
    required this.serverAddress,
    required this.username,
    required this.password,
    required this.cookie,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['service_name'] = Variable<String>(serviceName);
    map['server_address'] = Variable<String>(serverAddress);
    map['username'] = Variable<String>(username);
    map['password'] = Variable<String>(password);
    map['cookie'] = Variable<String>(cookie);
    return map;
  }

  ServerPropertiesCompanion toCompanion(bool nullToAbsent) {
    return ServerPropertiesCompanion(
      id: Value(id),
      serviceName: Value(serviceName),
      serverAddress: Value(serverAddress),
      username: Value(username),
      password: Value(password),
      cookie: Value(cookie),
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
      username: serializer.fromJson<String>(json['username']),
      password: serializer.fromJson<String>(json['password']),
      cookie: serializer.fromJson<String>(json['cookie']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serviceName': serializer.toJson<String>(serviceName),
      'serverAddress': serializer.toJson<String>(serverAddress),
      'username': serializer.toJson<String>(username),
      'password': serializer.toJson<String>(password),
      'cookie': serializer.toJson<String>(cookie),
    };
  }

  ServerProperty copyWith({
    int? id,
    String? serviceName,
    String? serverAddress,
    String? username,
    String? password,
    String? cookie,
  }) => ServerProperty(
    id: id ?? this.id,
    serviceName: serviceName ?? this.serviceName,
    serverAddress: serverAddress ?? this.serverAddress,
    username: username ?? this.username,
    password: password ?? this.password,
    cookie: cookie ?? this.cookie,
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
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      cookie: data.cookie.present ? data.cookie.value : this.cookie,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerProperty(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('serverAddress: $serverAddress, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('cookie: $cookie')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, serviceName, serverAddress, username, password, cookie);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerProperty &&
          other.id == this.id &&
          other.serviceName == this.serviceName &&
          other.serverAddress == this.serverAddress &&
          other.username == this.username &&
          other.password == this.password &&
          other.cookie == this.cookie);
}

class ServerPropertiesCompanion extends UpdateCompanion<ServerProperty> {
  final Value<int> id;
  final Value<String> serviceName;
  final Value<String> serverAddress;
  final Value<String> username;
  final Value<String> password;
  final Value<String> cookie;
  const ServerPropertiesCompanion({
    this.id = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.serverAddress = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.cookie = const Value.absent(),
  });
  ServerPropertiesCompanion.insert({
    this.id = const Value.absent(),
    required String serviceName,
    required String serverAddress,
    required String username,
    required String password,
    required String cookie,
  }) : serviceName = Value(serviceName),
       serverAddress = Value(serverAddress),
       username = Value(username),
       password = Value(password),
       cookie = Value(cookie);
  static Insertable<ServerProperty> custom({
    Expression<int>? id,
    Expression<String>? serviceName,
    Expression<String>? serverAddress,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? cookie,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceName != null) 'service_name': serviceName,
      if (serverAddress != null) 'server_address': serverAddress,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (cookie != null) 'cookie': cookie,
    });
  }

  ServerPropertiesCompanion copyWith({
    Value<int>? id,
    Value<String>? serviceName,
    Value<String>? serverAddress,
    Value<String>? username,
    Value<String>? password,
    Value<String>? cookie,
  }) {
    return ServerPropertiesCompanion(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      serverAddress: serverAddress ?? this.serverAddress,
      username: username ?? this.username,
      password: password ?? this.password,
      cookie: cookie ?? this.cookie,
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
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (cookie.present) {
      map['cookie'] = Variable<String>(cookie.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerPropertiesCompanion(')
          ..write('id: $id, ')
          ..write('serviceName: $serviceName, ')
          ..write('serverAddress: $serverAddress, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('cookie: $cookie')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [media, serverProperties];
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
      required String username,
      required String password,
      required String cookie,
    });
typedef $$ServerPropertiesTableUpdateCompanionBuilder =
    ServerPropertiesCompanion Function({
      Value<int> id,
      Value<String> serviceName,
      Value<String> serverAddress,
      Value<String> username,
      Value<String> password,
      Value<String> cookie,
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cookie => $composableBuilder(
    column: $table.cookie,
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cookie => $composableBuilder(
    column: $table.cookie,
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

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get cookie =>
      $composableBuilder(column: $table.cookie, builder: (column) => column);
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
                Value<String> username = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> cookie = const Value.absent(),
              }) => ServerPropertiesCompanion(
                id: id,
                serviceName: serviceName,
                serverAddress: serverAddress,
                username: username,
                password: password,
                cookie: cookie,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String serviceName,
                required String serverAddress,
                required String username,
                required String password,
                required String cookie,
              }) => ServerPropertiesCompanion.insert(
                id: id,
                serviceName: serviceName,
                serverAddress: serverAddress,
                username: username,
                password: password,
                cookie: cookie,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaTableTableManager get media =>
      $$MediaTableTableManager(_db, _db.media);
  $$ServerPropertiesTableTableManager get serverProperties =>
      $$ServerPropertiesTableTableManager(_db, _db.serverProperties);
}
