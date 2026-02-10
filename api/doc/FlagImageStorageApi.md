# openapi.api.FlagImageStorageApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8082*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deleteFlagImage**](FlagImageStorageApi.md#deleteflagimage) | **DELETE** /flag-image-storage/{id} | Delete flag image
[**downloadFlagImage**](FlagImageStorageApi.md#downloadflagimage) | **GET** /flag-image-storage/{id}/download | Download flag image
[**uploadFlagImage**](FlagImageStorageApi.md#uploadflagimage) | **POST** /flag-image-storage/ | Upload flag image


# **deleteFlagImage**
> deleteFlagImage(id)

Delete flag image

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FlagImageStorageApi();
final id = 789; // int | 

try {
    api_instance.deleteFlagImage(id);
} catch (e) {
    print('Exception when calling FlagImageStorageApi->deleteFlagImage: $e\n');
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

# **downloadFlagImage**
> MultipartFile downloadFlagImage(id)

Download flag image

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FlagImageStorageApi();
final id = 789; // int | 

try {
    final result = api_instance.downloadFlagImage(id);
    print(result);
} catch (e) {
    print('Exception when calling FlagImageStorageApi->downloadFlagImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**MultipartFile**](MultipartFile.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **uploadFlagImage**
> UploadFlagImageResponse uploadFlagImage(file, countryCode, countryName)

Upload flag image

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = FlagImageStorageApi();
final file = BINARY_DATA_HERE; // MultipartFile | 
final countryCode = countryCode_example; // String | 
final countryName = countryName_example; // String | 

try {
    final result = api_instance.uploadFlagImage(file, countryCode, countryName);
    print(result);
} catch (e) {
    print('Exception when calling FlagImageStorageApi->uploadFlagImage: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**|  | 
 **countryCode** | **String**|  | 
 **countryName** | **String**|  | 

### Return type

[**UploadFlagImageResponse**](UploadFlagImageResponse.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

