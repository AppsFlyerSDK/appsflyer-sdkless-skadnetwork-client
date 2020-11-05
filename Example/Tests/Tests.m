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
#import <OCMock/OCMock.h>

@interface AFSDKLessClient()
- (NSURL *)buildRequestURLWithUID:(NSString *)uid appId:(NSString *)appId devKey:(NSString *)devKey;
@end

@interface Tests : XCTestCase {
    XCTestExpectation *exp;
    id client;
}

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    exp = [self expectationWithDescription:@""];
    client = [AFSDKLessClient shared];
}

- (void)tearDown {
    exp = nil;
    client = nil;
    [super tearDown];
}

- (void)test_build_url {
    
    NSURL *requestURL = [client buildRequestURLWithUID:@"test_uid_1" appId:@"test_appid_1" devKey:@"dev_key"];
    NSString *quiery = [requestURL query];
    if ([quiery containsString:@"uid=test_uid_1&app_id=test_appid_1"]) {
        [exp fulfill];
    }
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_url_query_nil {
    NSString *nilUID = nil;
    NSString *nilAppID = nil;
    NSURL *requestURL = [client buildRequestURLWithUID:nilUID appId:nilAppID devKey:nil];
    NSString *query = [requestURL query];
    if (query == nil) {
        [exp fulfill];
    }
    [self waitForExpectationsWithTimeout:1 handler:nil];
}


- (void)test_request_ok{
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
        
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"value":@1} options:kNilOptions error:&error];
        return [HTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    
    
    [client requestConversionValueWithUID:@"uid" devKey:@"devKey" appID:@"00099922" completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        if ([result isEqual:@1]) {
            [exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_request_no_responce {
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
        
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error = [NSError errorWithDomain:@"domian" code:400 userInfo:nil];
        return [HTTPStubsResponse responseWithError:error];
    }];
    
    
    [client requestConversionValueWithUID:@"uid" devKey:@"devKey" appID:@"00099922" completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        if ([error.domain isEqualToString:@"domian"] && error.code == 400) {
            [exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_request_error_400{
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
        
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:&error];
        return [HTTPStubsResponse responseWithData:data statusCode:400 headers:nil];
    }];
    
    
    [client requestConversionValueWithUID:@"uid" devKey:@"devKey" appID:@"00099922" completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        if (error.code == 400 && [error.domain isEqualToString:@"Invalid request (params or headers missing or malformed)."]) {
            [exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_request_error_401{
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
        
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:&error];
        return [HTTPStubsResponse responseWithData:data statusCode:401 headers:nil];
    }];
    
    
    [client requestConversionValueWithUID:@"uid" devKey:@"devKey" appID:@"00099922" completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        if (error.code == 401 && [error.domain isEqualToString:@"Invalid signature."]) {
            [exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_request_error_404{
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
        
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:&error];
        return [HTTPStubsResponse responseWithData:data statusCode:404 headers:nil];
    }];
    
    
    [client requestConversionValueWithUID:@"uid" devKey:@"devKey" appID:@"00099922" completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        if (error.code == 404 && [error.domain isEqualToString:@"UID not found/expired."]) {
            [exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)test_request_error_503{
    [HTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.host isEqual:@"skadsdkless.appsflyer.com"];
        
    } withStubResponse:^HTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:&error];
        return [HTTPStubsResponse responseWithData:data statusCode:503 headers:nil];
    }];
    
    
    [client requestConversionValueWithUID:@"uid" devKey:@"devKey" appID:@"00099922" completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        if (error.code == 503 && [error.domain isEqualToString:@"Server busy"]) {
            [exp fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}




@end

