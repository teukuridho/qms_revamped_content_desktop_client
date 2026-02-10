//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class CurrencyExchangeRateRegistryApi {
  CurrencyExchangeRateRegistryApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Create one currency exchange rate
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateCurrencyExchangeRateRequest] createCurrencyExchangeRateRequest (required):
  Future<Response> createOneCurrencyExchangeRateWithHttpInfo(CreateCurrencyExchangeRateRequest createCurrencyExchangeRateRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/currency-exchange-rate-registry';

    // ignore: prefer_final_locals
    Object? postBody = createCurrencyExchangeRateRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Create one currency exchange rate
  ///
  /// Parameters:
  ///
  /// * [CreateCurrencyExchangeRateRequest] createCurrencyExchangeRateRequest (required):
  Future<CurrencyExchangeRateDto?> createOneCurrencyExchangeRate(CreateCurrencyExchangeRateRequest createCurrencyExchangeRateRequest,) async {
    final response = await createOneCurrencyExchangeRateWithHttpInfo(createCurrencyExchangeRateRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CurrencyExchangeRateDto',) as CurrencyExchangeRateDto;
    
    }
    return null;
  }

  /// Delete one currency exchange rate
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<Response> deleteOneCurrencyExchangeRateWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/currency-exchange-rate-registry/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Delete one currency exchange rate
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  Future<void> deleteOneCurrencyExchangeRate(int id,) async {
    final response = await deleteOneCurrencyExchangeRateWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }

  /// Get many currency exchange rates
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] page:
  ///   Zero-based page index (0..N)
  ///
  /// * [int] size:
  ///   The size of the page to be returned
  ///
  /// * [List<String>] sort:
  ///   Sorting criteria in the format: property,(asc|desc). Default sort order is ascending. Multiple sort criteria are supported.
  ///
  /// * [String] tag:
  Future<Response> getManyCurrencyExchangeRatesWithHttpInfo({ int? page, int? size, List<String>? sort, String? tag, }) async {
    // ignore: prefer_const_declarations
    final path = r'/currency-exchange-rate-registry';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (page != null) {
      queryParams.addAll(_queryParams('', 'page', page));
    }
    if (size != null) {
      queryParams.addAll(_queryParams('', 'size', size));
    }
    if (sort != null) {
      queryParams.addAll(_queryParams('multi', 'sort', sort));
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

  /// Get many currency exchange rates
  ///
  /// Parameters:
  ///
  /// * [int] page:
  ///   Zero-based page index (0..N)
  ///
  /// * [int] size:
  ///   The size of the page to be returned
  ///
  /// * [List<String>] sort:
  ///   Sorting criteria in the format: property,(asc|desc). Default sort order is ascending. Multiple sort criteria are supported.
  ///
  /// * [String] tag:
  Future<PageInfoResponseCurrencyExchangeRateDto?> getManyCurrencyExchangeRates({ int? page, int? size, List<String>? sort, String? tag, }) async {
    final response = await getManyCurrencyExchangeRatesWithHttpInfo( page: page, size: size, sort: sort, tag: tag, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PageInfoResponseCurrencyExchangeRateDto',) as PageInfoResponseCurrencyExchangeRateDto;
    
    }
    return null;
  }

  /// Update one currency exchange rate
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateCurrencyExchangeRateRequest] updateCurrencyExchangeRateRequest (required):
  Future<Response> updateOneCurrencyExchangeRateWithHttpInfo(int id, UpdateCurrencyExchangeRateRequest updateCurrencyExchangeRateRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/currency-exchange-rate-registry/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updateCurrencyExchangeRateRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update one currency exchange rate
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdateCurrencyExchangeRateRequest] updateCurrencyExchangeRateRequest (required):
  Future<CurrencyExchangeRateDto?> updateOneCurrencyExchangeRate(int id, UpdateCurrencyExchangeRateRequest updateCurrencyExchangeRateRequest,) async {
    final response = await updateOneCurrencyExchangeRateWithHttpInfo(id, updateCurrencyExchangeRateRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'CurrencyExchangeRateDto',) as CurrencyExchangeRateDto;
    
    }
    return null;
  }

  /// Update position
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdatePositionRequest] updatePositionRequest (required):
  Future<Response> updatePosition2WithHttpInfo(int id, UpdatePositionRequest updatePositionRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/currency-exchange-rate-registry/{id}/position'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = updatePositionRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Update position
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///
  /// * [UpdatePositionRequest] updatePositionRequest (required):
  Future<void> updatePosition2(int id, UpdatePositionRequest updatePositionRequest,) async {
    final response = await updatePosition2WithHttpInfo(id, updatePositionRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
