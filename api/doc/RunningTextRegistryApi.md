# openapi.api.RunningTextRegistryApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8082*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createRunningText**](RunningTextRegistryApi.md#createrunningtext) | **POST** /running-text-registry | Create running text
[**deleteRunningText**](RunningTextRegistryApi.md#deleterunningtext) | **DELETE** /running-text-registry/{id} | Delete running text
[**getMany**](RunningTextRegistryApi.md#getmany) | **GET** /running-text-registry | Get many running texts
[**getOneRunningTextByTag**](RunningTextRegistryApi.md#getonerunningtextbytag) | **GET** /running-text-registry/one | Get one running text by tag
[**updateRunningText**](RunningTextRegistryApi.md#updaterunningtext) | **PUT** /running-text-registry/{id} | Update running text


# **createRunningText**
> RunningTextDto createRunningText(createRunningTextRequest)

Create running text

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RunningTextRegistryApi();
final createRunningTextRequest = CreateRunningTextRequest(); // CreateRunningTextRequest | 

try {
    final result = api_instance.createRunningText(createRunningTextRequest);
    print(result);
} catch (e) {
    print('Exception when calling RunningTextRegistryApi->createRunningText: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createRunningTextRequest** | [**CreateRunningTextRequest**](CreateRunningTextRequest.md)|  | 

### Return type

[**RunningTextDto**](RunningTextDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteRunningText**
> deleteRunningText(id)

Delete running text

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RunningTextRegistryApi();
final id = 789; // int | 

try {
    api_instance.deleteRunningText(id);
} catch (e) {
    print('Exception when calling RunningTextRegistryApi->deleteRunningText: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getMany**
> PageInfoResponseRunningTextDto getMany(page, size, sort, tag)

Get many running texts

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RunningTextRegistryApi();
final page = 56; // int | Zero-based page index (0..N)
final size = 56; // int | The size of the page to be returned
final sort = []; // List<String> | Sorting criteria in the format: property,(asc|desc). Default sort order is ascending. Multiple sort criteria are supported.
final tag = tag_example; // String | 

try {
    final result = api_instance.getMany(page, size, sort, tag);
    print(result);
} catch (e) {
    print('Exception when calling RunningTextRegistryApi->getMany: $e\n');
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

[**PageInfoResponseRunningTextDto**](PageInfoResponseRunningTextDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getOneRunningTextByTag**
> RunningTextDto getOneRunningTextByTag(tag)

Get one running text by tag

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RunningTextRegistryApi();
final tag = tag_example; // String | 

try {
    final result = api_instance.getOneRunningTextByTag(tag);
    print(result);
} catch (e) {
    print('Exception when calling RunningTextRegistryApi->getOneRunningTextByTag: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tag** | **String**|  | 

### Return type

[**RunningTextDto**](RunningTextDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateRunningText**
> RunningTextDto updateRunningText(id, updateRunningTextRequest)

Update running text

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = RunningTextRegistryApi();
final id = 789; // int | 
final updateRunningTextRequest = UpdateRunningTextRequest(); // UpdateRunningTextRequest | 

try {
    final result = api_instance.updateRunningText(id, updateRunningTextRequest);
    print(result);
} catch (e) {
    print('Exception when calling RunningTextRegistryApi->updateRunningText: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateRunningTextRequest** | [**UpdateRunningTextRequest**](UpdateRunningTextRequest.md)|  | 

### Return type

[**RunningTextDto**](RunningTextDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

