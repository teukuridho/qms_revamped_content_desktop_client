//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PositionUpdatedSubscriber {
  /// Returns a new [PositionUpdatedSubscriber] instance.
  PositionUpdatedSubscriber({
    this.timeout,
    required this.id,
    required this.messageIndex,
    this.userId,
    this.tenantId,
    this.tag,
    this.tableName,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? timeout;

  int id;

  int messageIndex;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? userId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tenantId;

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
  String? tableName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PositionUpdatedSubscriber &&
    other.timeout == timeout &&
    other.id == id &&
    other.messageIndex == messageIndex &&
    other.userId == userId &&
    other.tenantId == tenantId &&
    other.tag == tag &&
    other.tableName == tableName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (timeout == null ? 0 : timeout!.hashCode) +
    (id.hashCode) +
    (messageIndex.hashCode) +
    (userId == null ? 0 : userId!.hashCode) +
    (tenantId == null ? 0 : tenantId!.hashCode) +
    (tag == null ? 0 : tag!.hashCode) +
    (tableName == null ? 0 : tableName!.hashCode);

  @override
  String toString() => 'PositionUpdatedSubscriber[timeout=$timeout, id=$id, messageIndex=$messageIndex, userId=$userId, tenantId=$tenantId, tag=$tag, tableName=$tableName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.timeout != null) {
      json[r'timeout'] = this.timeout;
    } else {
      json[r'timeout'] = null;
    }
      json[r'id'] = this.id;
      json[r'messageIndex'] = this.messageIndex;
    if (this.userId != null) {
      json[r'userId'] = this.userId;
    } else {
      json[r'userId'] = null;
    }
    if (this.tenantId != null) {
      json[r'tenantId'] = this.tenantId;
    } else {
      json[r'tenantId'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    if (this.tableName != null) {
      json[r'tableName'] = this.tableName;
    } else {
      json[r'tableName'] = null;
    }
    return json;
  }

  /// Returns a new [PositionUpdatedSubscriber] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PositionUpdatedSubscriber? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PositionUpdatedSubscriber[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PositionUpdatedSubscriber[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PositionUpdatedSubscriber(
        timeout: mapValueOfType<int>(json, r'timeout'),
        id: mapValueOfType<int>(json, r'id')!,
        messageIndex: mapValueOfType<int>(json, r'messageIndex')!,
        userId: mapValueOfType<int>(json, r'userId'),
        tenantId: mapValueOfType<String>(json, r'tenantId'),
        tag: mapValueOfType<String>(json, r'tag'),
        tableName: mapValueOfType<String>(json, r'tableName'),
      );
    }
    return null;
  }

  static List<PositionUpdatedSubscriber> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PositionUpdatedSubscriber>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PositionUpdatedSubscriber.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PositionUpdatedSubscriber> mapFromJson(dynamic json) {
    final map = <String, PositionUpdatedSubscriber>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PositionUpdatedSubscriber.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PositionUpdatedSubscriber-objects as value to a dart map
  static Map<String, List<PositionUpdatedSubscriber>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PositionUpdatedSubscriber>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PositionUpdatedSubscriber.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'messageIndex',
  };
}

