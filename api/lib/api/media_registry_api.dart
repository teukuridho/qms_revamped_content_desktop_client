//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class MediaRegistryApi {
  MediaRegistryApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Get many medias
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
  Future<Response> getMany2WithHttpInfo({ int? page, int? size, List<String>? sort, String? tag, }) async {
    // ignore: prefer_const_declarations
    final path = r'/media-registry';

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

  /// Get many medias
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
  Future<PageInfoResponseMediaDto?> getMany2({ int? page, int? size, List<String>? sort, String? tag, }) async {
    final response = await getMany2WithHttpInfo( page: page, size: size, sort: sort, tag: tag, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'PageInfoResponseMediaDto',) as PageInfoResponseMediaDto;
    
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
  Future<Response> updatePosition1WithHttpInfo(int id, UpdatePositionRequest updatePositionRequest,) async {
    // ignore: prefer_const_declarations
    final path = r'/media-registry/{id}/position'
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
  Future<void> updatePosition1(int id, UpdatePositionRequest updatePositionRequest,) async {
    final response = await updatePosition1WithHttpInfo(id, updatePositionRequest,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
  }
}
