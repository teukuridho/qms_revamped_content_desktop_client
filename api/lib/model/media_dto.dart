//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MediaDto {
  /// Returns a new [MediaDto] instance.
  MediaDto({
    required this.id,
    required this.tenantId,
    required this.objectKey,
    required this.contentType,
    required this.status,
    required this.position,
    required this.fileName,
    required this.mimeType,
    required this.tag,
  });

  int id;

  String tenantId;

  String objectKey;

  MediaDtoContentTypeEnum contentType;

  MediaDtoStatusEnum status;

  int position;

  String fileName;

  String mimeType;

  String tag;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaDto &&
    other.id == id &&
    other.tenantId == tenantId &&
    other.objectKey == objectKey &&
    other.contentType == contentType &&
    other.status == status &&
    other.position == position &&
    other.fileName == fileName &&
    other.mimeType == mimeType &&
    other.tag == tag;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (tenantId.hashCode) +
    (objectKey.hashCode) +
    (contentType.hashCode) +
    (status.hashCode) +
    (position.hashCode) +
    (fileName.hashCode) +
    (mimeType.hashCode) +
    (tag.hashCode);

  @override
  String toString() => 'MediaDto[id=$id, tenantId=$tenantId, objectKey=$objectKey, contentType=$contentType, status=$status, position=$position, fileName=$fileName, mimeType=$mimeType, tag=$tag]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'tenantId'] = this.tenantId;
      json[r'objectKey'] = this.objectKey;
      json[r'contentType'] = this.contentType;
      json[r'status'] = this.status;
      json[r'position'] = this.position;
      json[r'fileName'] = this.fileName;
      json[r'mimeType'] = this.mimeType;
      json[r'tag'] = this.tag;
    return json;
  }

  /// Returns a new [MediaDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MediaDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MediaDto(
        id: mapValueOfType<int>(json, r'id')!,
        tenantId: mapValueOfType<String>(json, r'tenantId')!,
        objectKey: mapValueOfType<String>(json, r'objectKey')!,
        contentType: MediaDtoContentTypeEnum.fromJson(json[r'contentType'])!,
        status: MediaDtoStatusEnum.fromJson(json[r'status'])!,
        position: mapValueOfType<int>(json, r'position')!,
        fileName: mapValueOfType<String>(json, r'fileName')!,
        mimeType: mapValueOfType<String>(json, r'mimeType')!,
        tag: mapValueOfType<String>(json, r'tag')!,
      );
    }
    return null;
  }

  static List<MediaDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaDto> mapFromJson(dynamic json) {
    final map = <String, MediaDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaDto-objects as value to a dart map
  static Map<String, List<MediaDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'tenantId',
    'objectKey',
    'contentType',
    'status',
    'position',
    'fileName',
    'mimeType',
    'tag',
  };
}


class MediaDtoContentTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const MediaDtoContentTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const VIDEO = MediaDtoContentTypeEnum._(r'VIDEO');
  static const IMAGE = MediaDtoContentTypeEnum._(r'IMAGE');

  /// List of all possible values in this [enum][MediaDtoContentTypeEnum].
  static const values = <MediaDtoContentTypeEnum>[
    VIDEO,
    IMAGE,
  ];

  static MediaDtoContentTypeEnum? fromJson(dynamic value) => MediaDtoContentTypeEnumTypeTransformer().decode(value);

  static List<MediaDtoContentTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaDtoContentTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaDtoContentTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MediaDtoContentTypeEnum] to String,
/// and [decode] dynamic data back to [MediaDtoContentTypeEnum].
class MediaDtoContentTypeEnumTypeTransformer {
  factory MediaDtoContentTypeEnumTypeTransformer() => _instance ??= const MediaDtoContentTypeEnumTypeTransformer._();

  const MediaDtoContentTypeEnumTypeTransformer._();

  String encode(MediaDtoContentTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MediaDtoContentTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MediaDtoContentTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'VIDEO': return MediaDtoContentTypeEnum.VIDEO;
        case r'IMAGE': return MediaDtoContentTypeEnum.IMAGE;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MediaDtoContentTypeEnumTypeTransformer] instance.
  static MediaDtoContentTypeEnumTypeTransformer? _instance;
}



class MediaDtoStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MediaDtoStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const UPLOADING = MediaDtoStatusEnum._(r'UPLOADING');
  static const READY = MediaDtoStatusEnum._(r'READY');
  static const DELETED = MediaDtoStatusEnum._(r'DELETED');

  /// List of all possible values in this [enum][MediaDtoStatusEnum].
  static const values = <MediaDtoStatusEnum>[
    UPLOADING,
    READY,
    DELETED,
  ];

  static MediaDtoStatusEnum? fromJson(dynamic value) => MediaDtoStatusEnumTypeTransformer().decode(value);

  static List<MediaDtoStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaDtoStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaDtoStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MediaDtoStatusEnum] to String,
/// and [decode] dynamic data back to [MediaDtoStatusEnum].
class MediaDtoStatusEnumTypeTransformer {
  factory MediaDtoStatusEnumTypeTransformer() => _instance ??= const MediaDtoStatusEnumTypeTransformer._();

  const MediaDtoStatusEnumTypeTransformer._();

  String encode(MediaDtoStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MediaDtoStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MediaDtoStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'UPLOADING': return MediaDtoStatusEnum.UPLOADING;
        case r'READY': return MediaDtoStatusEnum.READY;
        case r'DELETED': return MediaDtoStatusEnum.DELETED;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MediaDtoStatusEnumTypeTransformer] instance.
  static MediaDtoStatusEnumTypeTransformer? _instance;
}


