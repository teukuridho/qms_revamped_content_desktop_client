# openapi.api.PositionUpdatedSubscribeApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:8082*

Method | HTTP request | Description
------------- | ------------- | -------------
[**subscribe**](PositionUpdatedSubscribeApi.md#subscribe) | **GET** /position-updated-subscribe | Subscribe


# **subscribe**
> PositionUpdatedSubscriber subscribe(tableName, tag)

Subscribe

### Example
```dart
import 'package:openapi/api.dart';
// TODO Configure HTTP Bearer authorization: bearerAuth
// Case 1. Use String Token
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken('YOUR_ACCESS_TOKEN');
// Case 2. Use Function which generate token.
// String yourTokenGeneratorFunction() { ... }
//defaultApiClient.getAuthentication<HttpBearerAuth>('bearerAuth').setAccessToken(yourTokenGeneratorFunction);

final api_instance = PositionUpdatedSubscribeApi();
final tableName = tableName_example; // String | 
final tag = tag_example; // String | 

try {
    final result = api_instance.subscribe(tableName, tag);
    print(result);
} catch (e) {
    print('Exception when calling PositionUpdatedSubscribeApi->subscribe: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **tableName** | **String**|  | [optional] 
 **tag** | **String**|  | [optional] 

### Return type

[**PositionUpdatedSubscriber**](PositionUpdatedSubscriber.md)

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/event-stream

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

