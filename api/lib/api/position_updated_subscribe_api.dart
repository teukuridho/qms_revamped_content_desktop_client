//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class PositionUpdatedSubscribeApi {
  PositionUpdatedSubscribeApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Subscribe
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] tableName:
  ///
  /// * [String] tag:
  Future<Response> subscribeWithHttpInfo({ String? tableName, String? tag, }) async {
    // ignore: prefer_const_declarations
    final path = r'/position-updated-subscribe';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (tableName != null) {
      queryParams.addAll(_queryParams('', 'tableName', tableName));
    }
    if (tag != null) {
      queryParams.addAll(_queryParams('', 'tag', tag));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Subscribe
  ///
  /// Parameters:
  ///
  /// * [String] tableName:
  ///
  /// * [String] tag:
  Future<PositionUpdatedSubscriber?> subscribe({ String? tableName, String? tag, }) async {
    final response = await subscribeWithHttpInfo( tableName: tableName, tag: tag, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PositionUpdatedSubscriber',) as PositionUpdatedSubscriber;
    
    }
    return null;
  }
}
