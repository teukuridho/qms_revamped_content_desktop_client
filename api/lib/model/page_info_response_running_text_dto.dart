//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class PageInfoResponseRunningTextDto {
  /// Returns a new [PageInfoResponseRunningTextDto] instance.
  PageInfoResponseRunningTextDto({
    this.size,
    this.number,
    this.totalElements,
    this.totalPages,
    this.content = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? size;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? number;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalElements;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? totalPages;

  List<RunningTextDto> content;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PageInfoResponseRunningTextDto &&
    other.size == size &&
    other.number == number &&
    other.totalElements == totalElements &&
    other.totalPages == totalPages &&
    _deepEquality.equals(other.content, content);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (size == null ? 0 : size!.hashCode) +
    (number == null ? 0 : number!.hashCode) +
    (totalElements == null ? 0 : totalElements!.hashCode) +
    (totalPages == null ? 0 : totalPages!.hashCode) +
    (content.hashCode);

  @override
  String toString() => 'PageInfoResponseRunningTextDto[size=$size, number=$number, totalElements=$totalElements, totalPages=$totalPages, content=$content]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.size != null) {
      json[r'size'] = this.size;
    } else {
      json[r'size'] = null;
    }
    if (this.number != null) {
      json[r'number'] = this.number;
    } else {
      json[r'number'] = null;
    }
    if (this.totalElements != null) {
      json[r'totalElements'] = this.totalElements;
    } else {
      json[r'totalElements'] = null;
    }
    if (this.totalPages != null) {
      json[r'totalPages'] = this.totalPages;
    } else {
      json[r'totalPages'] = null;
    }
      json[r'content'] = this.content;
    return json;
  }

  /// Returns a new [PageInfoResponseRunningTextDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PageInfoResponseRunningTextDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PageInfoResponseRunningTextDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PageInfoResponseRunningTextDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PageInfoResponseRunningTextDto(
        size: mapValueOfType<int>(json, r'size'),
        number: mapValueOfType<int>(json, r'number'),
        totalElements: mapValueOfType<int>(json, r'totalElements'),
        totalPages: mapValueOfType<int>(json, r'totalPages'),
        content: RunningTextDto.listFromJson(json[r'content']),
      );
    }
    return null;
  }

  static List<PageInfoResponseRunningTextDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PageInfoResponseRunningTextDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PageInfoResponseRunningTextDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PageInfoResponseRunningTextDto> mapFromJson(dynamic json) {
    final map = <String, PageInfoResponseRunningTextDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PageInfoResponseRunningTextDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PageInfoResponseRunningTextDto-objects as value to a dart map
  static Map<String, List<PageInfoResponseRunningTextDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PageInfoResponseRunningTextDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PageInfoResponseRunningTextDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

