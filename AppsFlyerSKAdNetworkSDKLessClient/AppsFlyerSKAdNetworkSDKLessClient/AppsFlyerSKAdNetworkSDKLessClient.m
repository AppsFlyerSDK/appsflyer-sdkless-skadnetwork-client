//
//  AFSDKLessClient.m
//  AppsFlyerSDKLessSKAdNetworkClient
//
//  Created by Ivan Obodovskyi on 02.11.2020.
//


#import <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>

#import "AppsFlyerSKAdNetworkSDKLessClient.h"



@implementation AppsFlyerSKAdNetworkSDKLessClient {
    dispatch_queue_t sdkLessQueue;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        sdkLessQueue = dispatch_queue_create("sdkLessQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (AppsFlyerSKAdNetworkSDKLessClient *)shared {
    static AppsFlyerSKAdNetworkSDKLessClient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)requestConversionValueWithUID:(NSString *)clientID devKey:(NSString *)devKey appID:(NSString *)appID completionBlock:(void (^)(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error))completionBlock {
    dispatch_async(sdkLessQueue, ^{
        NSURL *url = [self buildRequestURLWithUID:clientID appId:appID devKey:devKey];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        NSDictionary *httpHeaderFields = [self buidRequestHeadersWithDevKey:devKey appID:appID uid:clientID];
        
        [request setHTTPMethod:@"GET"];
        [request setAllHTTPHeaderFields:httpHeaderFields];

        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(nil, error);
                });
                return;
            }
            
            if (response != nil) {
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                NSString *errorMessage = [self formatStatusCodeToErrorString:statusCode];
                
                if (errorMessage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(nil, [NSError errorWithDomain:errorMessage code:statusCode userInfo:nil]);
                    });
                    return;
                } else if (data) {
                    NSError *error;
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    if (result != nil && [result isKindOfClass:[NSDictionary class]]) {
                        SDKLessS2SMessage *s2sMessage = [[SDKLessS2SMessage alloc] initWithMessage:result];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionBlock(s2sMessage, error);
                        });
                    }
                    return;
                }
            }
        }];
        [dataTask resume];
    });
}

- (void)requestConversionValueWithDevKey:(NSString *)devKey
                                   appID:(NSString *)appID
                         completionHandler:(void (^)(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error))completionHandler {
    
    NSString *vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];    
    
    if (![vendorID isEqualToString:@""] && vendorID != nil) {
        [self requestConversionValueWithUID:vendorID devKey:devKey appID:appID completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, error);
                    return;
                });
            }
            
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(result, nil);
                    return;
                });
            }
        }];
    }
}

- (void)registerForAdNetworkAttribution {
    if (@available(iOS 16.1, *)) {
        [SKAdNetwork updatePostbackConversionValue:0 coarseValue:SKAdNetworkCoarseConversionValueHigh completionHandler:^(NSError * _Nullable error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }];
        return;
    }
    
    if (@available(iOS 15.4, *)) {
        [SKAdNetwork updatePostbackConversionValue:0 completionHandler:^(NSError * _Nullable error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }];
        return;
    }
    
    if (@available(iOS 11.3, *)) {
        [SKAdNetwork registerAppForAdNetworkAttribution];
        return;
    }
}

- (void)updateConversionValue:(NSInteger)converionValue {
    if (@available(iOS 14, *)) {
        [SKAdNetwork updateConversionValue:converionValue];
    }
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    if (@available(iOS 15.4, *)) {
        [SKAdNetwork updatePostbackConversionValue:conversionValue completionHandler:^(NSError * _Nullable error) {
            completionHandler(error);
        }];
    }
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                          coarseValue:(SKAdNetworkCoarseConversionValue)coarseValue
                    completionHandler:(void (^)(NSError * _Nullable error))completionHandler  API_AVAILABLE(ios(16.0)){
    if (@available(iOS 16.1, *)) {
        [SKAdNetwork updatePostbackConversionValue:conversionValue
                                       coarseValue:coarseValue
                                 completionHandler:^(NSError * _Nullable error) {
            completionHandler(error);
        }];
    }
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                          coarseValue:(SKAdNetworkCoarseConversionValue)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^)(NSError * _Nullable error))completionHandler {
    if (@available(iOS 16.1, *)) {
        [SKAdNetwork updatePostbackConversionValue:conversionValue
                                       coarseValue:coarseValue
                                        lockWindow:lockWindow
                                 completionHandler:^(NSError * _Nullable error) {
            completionHandler(error);
        }];
    }
}


//Method builds request url with following parameters. If one of them is nil, returns url without query params.
- (NSURL *)buildRequestURLWithUID:(NSString *)uid appId:(NSString *)appId devKey:(NSString *)devKey {
    NSURLComponents *queryURLComponents = [[NSURLComponents alloc] init];
    
    queryURLComponents.scheme = @"https";
    queryURLComponents.host = @"skadsdkless.appsflyer.com";
    queryURLComponents.path = @"/api/v2.0/conversion-value";
    
    if (uid != nil && appId != nil) {
        NSURLQueryItem *uidItem = [[NSURLQueryItem alloc] initWithName:@"uid" value:uid];
        NSURLQueryItem *appIdItem = [[NSURLQueryItem alloc] initWithName:@"app_id" value:appId];
        NSURLQueryItem *sdkVersion = [[NSURLQueryItem alloc] initWithName:@"sdk_version" value:@"sdk_less"];
        queryURLComponents.queryItems = @[appIdItem, uidItem, sdkVersion];
    }

    return queryURLComponents.URL;
}

//Returns NSDictionary, which parameters are used as request header fields.
- (NSDictionary *)buidRequestHeadersWithDevKey:(NSString *)devKey appID:(NSString *)appID uid:(NSString *)uid {
    if (!devKey && !appID && !uid) {
        return  nil;
    }
    
    NSTimeInterval currentTimeInSeconds = round([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *currentTimeString = [NSString stringWithFormat:@"%.0f", currentTimeInSeconds];
    NSString *encryptableString = [NSString stringWithFormat:@"%.0f%@%@", currentTimeInSeconds, appID, uid];
    
    //Dev key here is used as a secret key for HMAC-SHA256 encrypting algorythm
    NSString *hmacString = [self hmacForKey:devKey string:encryptableString];
    
    return @{
            @"Af-Timestamp" : currentTimeString,
            @"Authorization" : hmacString,
            };
}

- (NSString *)hmacForKey:(NSString *)key string:(NSString *)data {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }

    return HMAC;
}

- (NSString *)formatStatusCodeToErrorString:(NSInteger)statusCode {
    NSString *result = nil;
    
        switch(statusCode) {
            case 200:
                result = nil;
                break;
            case 400:
                result = @"Invalid request (params or headers missing or malformed).";
                break;
            case 401:
                result = @"Invalid signature.";
                break;
            case 404:
                result = @"UID not found/expired.";
                break;
            case 503:
                result = @"Server busy";
                break;
            default:
                result = @"Unexpected error";
        }

        return result;
}
@end
