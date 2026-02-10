//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class UpdateCurrencyExchangeRateRequest {
  /// Returns a new [UpdateCurrencyExchangeRateRequest] instance.
  UpdateCurrencyExchangeRateRequest({
    this.currencyCode,
    this.currencyName,
    this.flagImageId,
    this.buy,
    this.sell,
    this.tag,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? currencyCode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? currencyName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? flagImageId;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? buy;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? sell;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? tag;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateCurrencyExchangeRateRequest &&
    other.currencyCode == currencyCode &&
    other.currencyName == currencyName &&
    other.flagImageId == flagImageId &&
    other.buy == buy &&
    other.sell == sell &&
    other.tag == tag;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currencyCode == null ? 0 : currencyCode!.hashCode) +
    (currencyName == null ? 0 : currencyName!.hashCode) +
    (flagImageId == null ? 0 : flagImageId!.hashCode) +
    (buy == null ? 0 : buy!.hashCode) +
    (sell == null ? 0 : sell!.hashCode) +
    (tag == null ? 0 : tag!.hashCode);

  @override
  String toString() => 'UpdateCurrencyExchangeRateRequest[currencyCode=$currencyCode, currencyName=$currencyName, flagImageId=$flagImageId, buy=$buy, sell=$sell, tag=$tag]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.currencyCode != null) {
      json[r'currencyCode'] = this.currencyCode;
    } else {
      json[r'currencyCode'] = null;
    }
    if (this.currencyName != null) {
      json[r'currencyName'] = this.currencyName;
    } else {
      json[r'currencyName'] = null;
    }
    if (this.flagImageId != null) {
      json[r'flagImageId'] = this.flagImageId;
    } else {
      json[r'flagImageId'] = null;
    }
    if (this.buy != null) {
      json[r'buy'] = this.buy;
    } else {
      json[r'buy'] = null;
    }
    if (this.sell != null) {
      json[r'sell'] = this.sell;
    } else {
      json[r'sell'] = null;
    }
    if (this.tag != null) {
      json[r'tag'] = this.tag;
    } else {
      json[r'tag'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateCurrencyExchangeRateRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateCurrencyExchangeRateRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateCurrencyExchangeRateRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateCurrencyExchangeRateRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateCurrencyExchangeRateRequest(
        currencyCode: mapValueOfType<String>(json, r'currencyCode'),
        currencyName: mapValueOfType<String>(json, r'currencyName'),
        flagImageId: mapValueOfType<int>(json, r'flagImageId'),
        buy: mapValueOfType<int>(json, r'buy'),
        sell: mapValueOfType<int>(json, r'sell'),
        tag: mapValueOfType<String>(json, r'tag'),
      );
    }
    return null;
  }

  static List<UpdateCurrencyExchangeRateRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateCurrencyExchangeRateRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateCurrencyExchangeRateRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateCurrencyExchangeRateRequest> mapFromJson(dynamic json) {
    final map = <String, UpdateCurrencyExchangeRateRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateCurrencyExchangeRateRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateCurrencyExchangeRateRequest-objects as value to a dart map
  static Map<String, List<UpdateCurrencyExchangeRateRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateCurrencyExchangeRateRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateCurrencyExchangeRateRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

