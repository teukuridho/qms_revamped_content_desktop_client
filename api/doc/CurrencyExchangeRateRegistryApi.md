# openapi.api.CurrencyExchangeRateRegistryApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://192.168.137.7:8082*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createOneCurrencyExchangeRate**](CurrencyExchangeRateRegistryApi.md#createonecurrencyexchangerate) | **POST** /currency-exchange-rate-registry | Create one currency exchange rate
[**deleteOneCurrencyExchangeRate**](CurrencyExchangeRateRegistryApi.md#deleteonecurrencyexchangerate) | **DELETE** /currency-exchange-rate-registry/{id} | Delete one currency exchange rate
[**getManyCurrencyExchangeRates**](CurrencyExchangeRateRegistryApi.md#getmanycurrencyexchangerates) | **GET** /currency-exchange-rate-registry | Get many currency exchange rates
[**updateOneCurrencyExchangeRate**](CurrencyExchangeRateRegistryApi.md#updateonecurrencyexchangerate) | **PUT** /currency-exchange-rate-registry/{id} | Update one currency exchange rate
[**updatePosition2**](CurrencyExchangeRateRegistryApi.md#updateposition2) | **PUT** /currency-exchange-rate-registry/{id}/position | Update position


# **createOneCurrencyExchangeRate**
> CurrencyExchangeRateDto createOneCurrencyExchangeRate(createCurrencyExchangeRateRequest)

Create one currency exchange rate

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CurrencyExchangeRateRegistryApi();
final createCurrencyExchangeRateRequest = CreateCurrencyExchangeRateRequest(); // CreateCurrencyExchangeRateRequest | 

try {
    final result = api_instance.createOneCurrencyExchangeRate(createCurrencyExchangeRateRequest);
    print(result);
} catch (e) {
    print('Exception when calling CurrencyExchangeRateRegistryApi->createOneCurrencyExchangeRate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createCurrencyExchangeRateRequest** | [**CreateCurrencyExchangeRateRequest**](CreateCurrencyExchangeRateRequest.md)|  | 

### Return type

[**CurrencyExchangeRateDto**](CurrencyExchangeRateDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteOneCurrencyExchangeRate**
> deleteOneCurrencyExchangeRate(id)

Delete one currency exchange rate

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CurrencyExchangeRateRegistryApi();
final id = 789; // int | 

try {
    api_instance.deleteOneCurrencyExchangeRate(id);
} catch (e) {
    print('Exception when calling CurrencyExchangeRateRegistryApi->deleteOneCurrencyExchangeRate: $e\n');
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

# **getManyCurrencyExchangeRates**
> PageInfoResponseCurrencyExchangeRateDto getManyCurrencyExchangeRates(page, size, sort, tag)

Get many currency exchange rates

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CurrencyExchangeRateRegistryApi();
final page = 56; // int | Zero-based page index (0..N)
final size = 56; // int | The size of the page to be returned
final sort = []; // List<String> | Sorting criteria in the format: property,(asc|desc). Default sort order is ascending. Multiple sort criteria are supported.
final tag = tag_example; // String | 

try {
    final result = api_instance.getManyCurrencyExchangeRates(page, size, sort, tag);
    print(result);
} catch (e) {
    print('Exception when calling CurrencyExchangeRateRegistryApi->getManyCurrencyExchangeRates: $e\n');
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

[**PageInfoResponseCurrencyExchangeRateDto**](PageInfoResponseCurrencyExchangeRateDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateOneCurrencyExchangeRate**
> CurrencyExchangeRateDto updateOneCurrencyExchangeRate(id, updateCurrencyExchangeRateRequest)

Update one currency exchange rate

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = CurrencyExchangeRateRegistryApi();
final id = 789; // int | 
final updateCurrencyExchangeRateRequest = UpdateCurrencyExchangeRateRequest(); // UpdateCurrencyExchangeRateRequest | 

try {
    final result = api_instance.updateOneCurrencyExchangeRate(id, updateCurrencyExchangeRateRequest);
    print(result);
} catch (e) {
    print('Exception when calling CurrencyExchangeRateRegistryApi->updateOneCurrencyExchangeRate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **updateCurrencyExchangeRateRequest** | [**UpdateCurrencyExchangeRateRequest**](UpdateCurrencyExchangeRateRequest.md)|  | 

### Return type

[**CurrencyExchangeRateDto**](CurrencyExchangeRateDto.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updatePosition2**
> updatePosition2(id, updatePositionRequest)

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

final api_instance = CurrencyExchangeRateRegistryApi();
final id = 789; // int | 
final updatePositionRequest = UpdatePositionRequest(); // UpdatePositionRequest | 

try {
    api_instance.updatePosition2(id, updatePositionRequest);
} catch (e) {
    print('Exception when calling CurrencyExchangeRateRegistryApi->updatePosition2: $e\n');
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

