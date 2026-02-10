//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/currency_exchange_rate_initializer_api.dart';
part 'api/currency_exchange_rate_registry_api.dart';
part 'api/flag_image_initializer_api.dart';
part 'api/flag_image_registry_api.dart';
part 'api/flag_image_storage_api.dart';
part 'api/media_initializer_api.dart';
part 'api/media_registry_api.dart';
part 'api/media_storage_api.dart';
part 'api/position_updated_subscribe_api.dart';
part 'api/product_initializer_api.dart';
part 'api/product_registry_api.dart';
part 'api/running_text_initializer_api.dart';
part 'api/running_text_registry_api.dart';
part 'api/secure_controller_api.dart';

part 'model/create_currency_exchange_rate_request.dart';
part 'model/create_product_request.dart';
part 'model/create_running_text_request.dart';
part 'model/currency_exchange_rate_created_event_dto.dart';
part 'model/currency_exchange_rate_deleted_event_dto.dart';
part 'model/currency_exchange_rate_dto.dart';
part 'model/currency_exchange_rate_updated_event_dto.dart';
part 'model/flag_image_dto.dart';
part 'model/media_deleted_event_dto.dart';
part 'model/media_dto.dart';
part 'model/media_uploaded_event_dto.dart';
part 'model/orderable_affected_record.dart';
part 'model/page_info_response_currency_exchange_rate_dto.dart';
part 'model/page_info_response_flag_image_dto.dart';
part 'model/page_info_response_media_dto.dart';
part 'model/page_info_response_product_dto.dart';
part 'model/page_info_response_running_text_dto.dart';
part 'model/position_updated_event_dto.dart';
part 'model/position_updated_subscriber.dart';
part 'model/product_created_event_dto.dart';
part 'model/product_deleted_event_dto.dart';
part 'model/product_dto.dart';
part 'model/product_updated_event_dto.dart';
part 'model/running_text_dto.dart';
part 'model/subscribe_position_updated_request.dart';
part 'model/update_currency_exchange_rate_request.dart';
part 'model/update_position_request.dart';
part 'model/update_product_request.dart';
part 'model/update_running_text_request.dart';
part 'model/upload_flag_image_response.dart';
part 'model/upload_media_response.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';
