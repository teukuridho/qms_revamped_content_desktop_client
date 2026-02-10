# openapi.api.MediaRegistryApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8082*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getMany2**](MediaRegistryApi.md#getmany2) | **GET** /media-registry | Get many medias
[**updatePosition1**](MediaRegistryApi.md#updateposition1) | **PUT** /media-registry/{id}/position | Update position


# **getMany2**
> PageInfoResponseMediaDto getMany2(page, size, sort, tag)

Get many medias

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MediaRegistryApi();
final page = 56; // int | Zero-based page index (0..N)
final size = 56; // int | The size of the page to be returned
final sort = []; // List<String> | Sorting criteria in the format: property,(asc|desc). Default sort order is ascending. Multiple sort criteria are supported.
final tag = tag_example; // String | 

try {
    final result = api_instance.getMany2(page, size, sort, tag);
    print(result);
} catch (e) {
    print('Exception when calling MediaRegistryApi->getMany2: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**| Zero-based page index (0..N) | [optional] [default to 0]
 **size** | **int**| The size of the page to be returned | [optional] [default to 20]
 **sort** | [**List<String>**](String.md)| Sorting criteria in the format: property,(asc|desc). Default sort order is ascending. Multiple sort criteria are supported. | [optional] [default to const []]
 **tag** | **String**|  | [optional] 

### Return type

[**PageInfoResponseMediaDto**](PageInfoResponseMediaDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePosition1**
> updatePosition1(id, updatePositionRequest)

Update position

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = MediaRegistryApi();
final id = 789; // int | 
final updatePositionRequest = UpdatePositionRequest(); // UpdatePositionRequest | 

try {
    api_instance.updatePosition1(id, updatePositionRequest);
} catch (e) {
    print('Exception when calling MediaRegistryApi->updatePosition1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updatePositionRequest** | [**UpdatePositionRequest**](UpdatePositionRequest.md)|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

