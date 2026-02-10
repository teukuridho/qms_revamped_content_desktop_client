//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CreateProductRequest {
  /// Returns a new [CreateProductRequest] instance.
  CreateProductRequest({
    required this.name,
    required this.value,
    required this.tag,
  });

  String name;

  String value;

  String tag;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CreateProductRequest &&
    other.name == name &&
    other.value == value &&
    other.tag == tag;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (value.hashCode) +
    (tag.hashCode);

  @override
  String toString() => 'CreateProductRequest[name=$name, value=$value, tag=$tag]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'value'] = this.value;
      json[r'tag'] = this.tag;
    return json;
  }

  /// Returns a new [CreateProductRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CreateProductRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CreateProductRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CreateProductRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CreateProductRequest(
        name: mapValueOfType<String>(json, r'name')!,
        value: mapValueOfType<String>(json, r'value')!,
        tag: mapValueOfType<String>(json, r'tag')!,
      );
    }
    return null;
  }

  static List<CreateProductRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CreateProductRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CreateProductRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CreateProductRequest> mapFromJson(dynamic json) {
    final map = <String, CreateProductRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CreateProductRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CreateProductRequest-objects as value to a dart map
  static Map<String, List<CreateProductRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CreateProductRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CreateProductRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'value',
    'tag',
  };
}

