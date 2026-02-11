//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class CurrencyExchangeRateDto {
  /// Returns a new [CurrencyExchangeRateDto] instance.
  CurrencyExchangeRateDto({
    required this.id,
    required this.tenantId,
    required this.currencyCode,
    required this.currencyName,
    this.flagImageId,
    this.buy,
    this.sell,
    required this.position,
    required this.tag,
  });

  int id;

  String tenantId;

  String currencyCode;

  String currencyName;

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
  double? buy;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? sell;

  int position;

  String tag;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CurrencyExchangeRateDto &&
    other.id == id &&
    other.tenantId == tenantId &&
    other.currencyCode == currencyCode &&
    other.currencyName == currencyName &&
    other.flagImageId == flagImageId &&
    other.buy == buy &&
    other.sell == sell &&
    other.position == position &&
    other.tag == tag;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (tenantId.hashCode) +
    (currencyCode.hashCode) +
    (currencyName.hashCode) +
    (flagImageId == null ? 0 : flagImageId!.hashCode) +
    (buy == null ? 0 : buy!.hashCode) +
    (sell == null ? 0 : sell!.hashCode) +
    (position.hashCode) +
    (tag.hashCode);

  @override
  String toString() => 'CurrencyExchangeRateDto[id=$id, tenantId=$tenantId, currencyCode=$currencyCode, currencyName=$currencyName, flagImageId=$flagImageId, buy=$buy, sell=$sell, position=$position, tag=$tag]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'tenantId'] = this.tenantId;
      json[r'currencyCode'] = this.currencyCode;
      json[r'currencyName'] = this.currencyName;
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
      json[r'position'] = this.position;
      json[r'tag'] = this.tag;
    return json;
  }

  /// Returns a new [CurrencyExchangeRateDto] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CurrencyExchangeRateDto? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CurrencyExchangeRateDto[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "CurrencyExchangeRateDto[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return CurrencyExchangeRateDto(
        id: mapValueOfType<int>(json, r'id')!,
        tenantId: mapValueOfType<String>(json, r'tenantId')!,
        currencyCode: mapValueOfType<String>(json, r'currencyCode')!,
        currencyName: mapValueOfType<String>(json, r'currencyName')!,
        flagImageId: mapValueOfType<int>(json, r'flagImageId'),
        buy: mapValueOfType<double>(json, r'buy'),
        sell: mapValueOfType<double>(json, r'sell'),
        position: mapValueOfType<int>(json, r'position')!,
        tag: mapValueOfType<String>(json, r'tag')!,
      );
    }
    return null;
  }

  static List<CurrencyExchangeRateDto> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CurrencyExchangeRateDto>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CurrencyExchangeRateDto.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CurrencyExchangeRateDto> mapFromJson(dynamic json) {
    final map = <String, CurrencyExchangeRateDto>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CurrencyExchangeRateDto.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CurrencyExchangeRateDto-objects as value to a dart map
  static Map<String, List<CurrencyExchangeRateDto>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CurrencyExchangeRateDto>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CurrencyExchangeRateDto.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'tenantId',
    'currencyCode',
    'currencyName',
    'position',
    'tag',
  };
}

