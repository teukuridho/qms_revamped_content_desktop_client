//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PositionUpdatedEventDto {
  /// Returns a new [PositionUpdatedEventDto] instance.
  PositionUpdatedEventDto({
    this.tableName,
    this.tag,
    this.id,
    this.newPosition,
    this.affectedRecordRows = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tableName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? newPosition;

  List<OrderableAffectedRecord> affectedRecordRows;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PositionUpdatedEventDto &&
    other.tableName == tableName &&
    other.tag == tag &&
    other.id == id &&
    other.newPosition == newPosition &&
    _deepEquality.equals(other.affectedRecordRows, affectedRecordRows);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (tableName == null ? 0 : tableName!.hashCode) +
    (tag == null ? 0 : tag!.hashCode) +
    (id == null ? 0 : id!.hashCode) +
    (newPosition == null ? 0 : newPosition!.hashCode) +
    (affectedRecordRows.hashCode);

  @override
  String toString() => 'PositionUpdatedEventDto[tableName=$tableName, tag=$tag, id=$id, newPosition=$newPosition, affectedRecordRows=$affectedRecordRows]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.tableName != null) {
      json[r'tableName'] = this.tableName;
    } else {
      json[r'tableName'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.newPosition != null) {
      json[r'newPosition'] = this.newPosition;
    } else {
      json[r'newPosition'] = null;
    }
      json[r'affectedRecordRows'] = this.affectedRecordRows;
    return json;
  }

  /// Returns a new [PositionUpdatedEventDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PositionUpdatedEventDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PositionUpdatedEventDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PositionUpdatedEventDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PositionUpdatedEventDto(
        tableName: mapValueOfType<String>(json, r'tableName'),
        tag: mapValueOfType<String>(json, r'tag'),
        id: mapValueOfType<int>(json, r'id'),
        newPosition: mapValueOfType<int>(json, r'newPosition'),
        affectedRecordRows: OrderableAffectedRecord.listFromJson(json[r'affectedRecordRows']),
      );
    }
    return null;
  }

  static List<PositionUpdatedEventDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PositionUpdatedEventDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PositionUpdatedEventDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PositionUpdatedEventDto> mapFromJson(dynamic json) {
    final map = <String, PositionUpdatedEventDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PositionUpdatedEventDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PositionUpdatedEventDto-objects as value to a dart map
  static Map<String, List<PositionUpdatedEventDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PositionUpdatedEventDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PositionUpdatedEventDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

