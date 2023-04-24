//
//  AppsFlyerSDKLessSKAdNetworkClientTests.m
//  AppsFlyerSDKLessSKAdNetworkClientTests
//
//  Created by Ivan on 11/02/2020.
//  Copyright (c) 2020 Ivan. All rights reserved.
//

@import XCTest;
#import <AFSDKLessClient.h>
#import <OHHTTPStubs/HTTPStubs.h>
#import <OHHTTPStubs/HTTPStubsResponse+JSON.h>
#import <OCMock/OCMock.h>

@interface AFSDKLessClient()
- (NSURL *)buildRequestURLWithUID:(NSString *)uid appId:(NSString *)appId devKey:(NSString *)devKey;
- (NSDictionary *)buidRequestHeadersWithDevKey:(NSString *)devKey appID:(NSString *)appID uid:(NSString *)uid;
@end

@interface Tests : XCTestCase {
    XCTestExpectation *exp;
    id client;
}

@end

@implementation Tests

- (void)setUp {
    exp = [self expectationWithDescription:@""];
    client = [AFSDKLessClient shared];
}

- (void)tearDown {
    exp = nil;
    client = nil;
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_build_url {
    NSURL *requestURL = [client buildRequestURLWithUID:@"testAppsFlyerSKAdNetworkSDKLessClient_uid_1" appId:@"testAppsFlyerSKAdNetworkSDKLessClient_appid_1" devKey:@"dev_key"];
    NSString *quiery = [requestURL query];
    if ([quiery isEqualToString:@"app_id=testAppsFlyerSKAdNetworkSDKLessClient_appid_1&uid=testAppsFlyerSKAdNetworkSDKLessClient_uid_1&sdk_version=sdk_less"]) {
        [exp fulfill];
    }
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClienturl_query_nil {
    NSString *nilUID = nil;
    NSString *nilAppID = nil;
    NSURL *requestURL = [client buildRequestURLWithUID:nilUID appId:nilAppID devKey:nil];
    NSString *query = [requestURL query];
    if (query == nil) {
        [exp fulfill];
    }
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_ok_skanDefault{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{@"value":@1} statusCode:200]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (result.conversionValue == 1 && [result configMode] == AFSDKSKANModeDefault) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_ok_skan4mode {
    NSDictionary *skan4Config = @{
        @"value": @(63),
        @"coarse_value": @"high",
        @"lock":@(YES),
        @"next_w_time": @(1672147423),
        @"postback_sequence_index": @(2)
    };
    
    [self stubRequestForTesting:[self responseMockWithJSONObject:skan4Config
                                                      statusCode:200]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (result.conversionValue == 63 &&
            [result configMode] == AFSDKSKANModeV4 &&
            [[result coarseValue] isEqualToString: @"high"] &&
            [result postbackSequenceIndex] == 2) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_no_responce {
    [self stubRequestForTesting:[self responseErrorWithDomain:@"domian" statusCode:400 userInfo:nil]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if ([error.domain isEqualToString:@"domian"] && error.code == 400) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_error_400{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:400]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage* _Nullable result, NSError * _Nullable error) {
        if (error.code == 400 && [error.domain isEqualToString:@"Invalid request (params or headers missing or malformed)."]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_error_401{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:401]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 401 && [error.domain isEqualToString:@"Invalid signature."]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_error_404{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:404]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 404 && [error.domain isEqualToString:@"UID not found/expired."]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_error_503{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:503]];
    
    [client requestConversionValueWithUID:@"uid"
                                   devKey:@"devKey"
                                    appID:@"00099922"
                          completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 503 && [error.domain isEqualToString:@"Server busy"]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_vendor_request_200 {
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{@"value":@1} statusCode:200]];
    
    [client requestConversionValueWithDevKey:@"dev_key"
                                       appID:@"app_id"
                           completionHandler:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if ([result conversionValue]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_vendor_request_no_responce {
    [self stubRequestForTesting:[self responseErrorWithDomain:@"domain" statusCode:400 userInfo:nil]];
    
    [client requestConversionValueWithDevKey:@"dev_key"
                                       appID:@"app_id"
                           completionHandler:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if ([error.domain isEqualToString:@"domain"] && error.code == 400) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_vendor_id_error_400{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:400]];
    
    [client requestConversionValueWithDevKey:@"dev_key"
                                       appID:@"app_id"
                           completionHandler:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 400 && [error.domain isEqualToString:@"Invalid request (params or headers missing or malformed)."]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_vendor_error_401{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:401]];
    
    [client requestConversionValueWithDevKey:@"dev_key"
                                       appID:@"app_id"
                           completionHandler:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 401 && [error.domain isEqualToString:@"Invalid signature."]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_vendor_error_404{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:404]];
    
    [client requestConversionValueWithDevKey:@"dev_key"
                                       appID:@"app_id"
                           completionHandler:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 404 && [error.domain isEqualToString:@"UID not found/expired."]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testAppsFlyerSKAdNetworkSDKLessClient_request_vendor_error_503{
    [self stubRequestForTesting:[self responseMockWithJSONObject:@{} statusCode:503]];
    
    [client requestConversionValueWithDevKey:@"dev_key"
                                       appID:@"app_id"
                           completionHandler:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
        if (error.code == 503 && [error.domain isEqualToString:@"Server busy"]) {
            [self->exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)stubRequestForTesting:(HTTPStubsResponse *)response {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return response;
    }];
}

- (HTTPStubsResponse *)responseMockWithJSONObject:(NSDictionary *)dictionary statusCode:(int)statusCode {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:&error];
    return [HTTPStubsResponse responseWithData:data statusCode:statusCode headers:nil];
}

- (HTTPStubsResponse *)responseErrorWithDomain:(NSString *)domain
                                    statusCode:(int)statusCode
                                      userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)dict {
    NSError *error = [NSError errorWithDomain:domain code:statusCode userInfo:dict];
    return [HTTPStubsResponse responseWithError:error];
}


@end
