//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class FlagImageDto {
  /// Returns a new [FlagImageDto] instance.
  FlagImageDto({
    required this.id,
    required this.tenantId,
    required this.objectKey,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.countryCode,
    required this.countryName,
  });

  int id;

  String tenantId;

  String objectKey;

  String fileName;

  String mimeType;

  int sizeBytes;

  String countryCode;

  String countryName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is FlagImageDto &&
    other.id == id &&
    other.tenantId == tenantId &&
    other.objectKey == objectKey &&
    other.fileName == fileName &&
    other.mimeType == mimeType &&
    other.sizeBytes == sizeBytes &&
    other.countryCode == countryCode &&
    other.countryName == countryName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (tenantId.hashCode) +
    (objectKey.hashCode) +
    (fileName.hashCode) +
    (mimeType.hashCode) +
    (sizeBytes.hashCode) +
    (countryCode.hashCode) +
    (countryName.hashCode);

  @override
  String toString() => 'FlagImageDto[id=$id, tenantId=$tenantId, objectKey=$objectKey, fileName=$fileName, mimeType=$mimeType, sizeBytes=$sizeBytes, countryCode=$countryCode, countryName=$countryName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'tenantId'] = this.tenantId;
      json[r'objectKey'] = this.objectKey;
      json[r'fileName'] = this.fileName;
      json[r'mimeType'] = this.mimeType;
      json[r'sizeBytes'] = this.sizeBytes;
      json[r'countryCode'] = this.countryCode;
      json[r'countryName'] = this.countryName;
    return json;
  }

  /// Returns a new [FlagImageDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static FlagImageDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "FlagImageDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "FlagImageDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return FlagImageDto(
        id: mapValueOfType<int>(json, r'id')!,
        tenantId: mapValueOfType<String>(json, r'tenantId')!,
        objectKey: mapValueOfType<String>(json, r'objectKey')!,
        fileName: mapValueOfType<String>(json, r'fileName')!,
        mimeType: mapValueOfType<String>(json, r'mimeType')!,
        sizeBytes: mapValueOfType<int>(json, r'sizeBytes')!,
        countryCode: mapValueOfType<String>(json, r'countryCode')!,
        countryName: mapValueOfType<String>(json, r'countryName')!,
      );
    }
    return null;
  }

  static List<FlagImageDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <FlagImageDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = FlagImageDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, FlagImageDto> mapFromJson(dynamic json) {
    final map = <String, FlagImageDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = FlagImageDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of FlagImageDto-objects as value to a dart map
  static Map<String, List<FlagImageDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<FlagImageDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = FlagImageDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'tenantId',
    'objectKey',
    'fileName',
    'mimeType',
    'sizeBytes',
    'countryCode',
    'countryName',
  };
}

