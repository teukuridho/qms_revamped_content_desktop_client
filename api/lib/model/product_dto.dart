//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ProductDto {
  /// Returns a new [ProductDto] instance.
  ProductDto({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.value,
    required this.tag,
    required this.position,
  });

  int id;

  String tenantId;

  String name;

  String value;

  String tag;

  int position;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ProductDto &&
    other.id == id &&
    other.tenantId == tenantId &&
    other.name == name &&
    other.value == value &&
    other.tag == tag &&
    other.position == position;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (tenantId.hashCode) +
    (name.hashCode) +
    (value.hashCode) +
    (tag.hashCode) +
    (position.hashCode);

  @override
  String toString() => 'ProductDto[id=$id, tenantId=$tenantId, name=$name, value=$value, tag=$tag, position=$position]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'tenantId'] = this.tenantId;
      json[r'name'] = this.name;
      json[r'value'] = this.value;
      json[r'tag'] = this.tag;
      json[r'position'] = this.position;
    return json;
  }

  /// Returns a new [ProductDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ProductDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ProductDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ProductDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ProductDto(
        id: mapValueOfType<int>(json, r'id')!,
        tenantId: mapValueOfType<String>(json, r'tenantId')!,
        name: mapValueOfType<String>(json, r'name')!,
        value: mapValueOfType<String>(json, r'value')!,
        tag: mapValueOfType<String>(json, r'tag')!,
        position: mapValueOfType<int>(json, r'position')!,
      );
    }
    return null;
  }

  static List<ProductDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ProductDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ProductDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ProductDto> mapFromJson(dynamic json) {
    final map = <String, ProductDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ProductDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ProductDto-objects as value to a dart map
  static Map<String, List<ProductDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ProductDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ProductDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'tenantId',
    'name',
    'value',
    'tag',
    'position',
  };
}

