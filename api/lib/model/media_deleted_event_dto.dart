//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MediaDeletedEventDto {
  /// Returns a new [MediaDeletedEventDto] instance.
  MediaDeletedEventDto({
    required this.id,
  });

  int id;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaDeletedEventDto &&
    other.id == id;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode);

  @override
  String toString() => 'MediaDeletedEventDto[id=$id]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    return json;
  }

  /// Returns a new [MediaDeletedEventDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaDeletedEventDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaDeletedEventDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MediaDeletedEventDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MediaDeletedEventDto(
        id: mapValueOfType<int>(json, r'id')!,
      );
    }
    return null;
  }

  static List<MediaDeletedEventDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaDeletedEventDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaDeletedEventDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaDeletedEventDto> mapFromJson(dynamic json) {
    final map = <String, MediaDeletedEventDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaDeletedEventDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaDeletedEventDto-objects as value to a dart map
  static Map<String, List<MediaDeletedEventDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaDeletedEventDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaDeletedEventDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
  };
}

