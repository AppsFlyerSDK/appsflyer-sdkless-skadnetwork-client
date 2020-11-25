//
//  AFSDKLessClient.m
//  AppsFlyerSDKLessSKAdNetworkClient
//
//  Created by Ivan Obodovskyi on 02.11.2020.
//

#import "AFSDKLessClient.h"
#import <StoreKit/SKAdNetwork.h>
#import <CommonCrypto/CommonHMAC.h>


@implementation AFSDKLessClient {
    dispatch_queue_t sdkLessQueue;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        sdkLessQueue = dispatch_queue_create("sdkLessQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (AFSDKLessClient *)shared {
    static AFSDKLessClient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)requestConversionValueWithUID:(NSString *)clientID devKey:(NSString *)devKey appID:(NSString *)appID completionBlock:(void (^)(NSNumber * _Nullable result, NSError * _Nullable error))completionBlock {
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
                    // TODO: add check for 'isKindOf: Class' in future.
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSNumber *conversionValue = (NSNumber *)result[@"value"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionBlock(conversionValue, error);
                    });
                    return;
                }
            }
        }];
        [dataTask resume];
    });
}

- (void)requestConversionValueWithDevKey:(NSString *)devKey
                                   appID:(NSString *)appID
                         completionHandler:(void (^)(NSNumber * _Nullable result, NSError * _Nullable error))completionHandler {
    
    NSString *vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];    
    
    if (![vendorID isEqualToString:@""] && vendorID != nil) {
        [self requestConversionValueWithUID:vendorID devKey:devKey appID:appID completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
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
    if (@available(iOS 11.3, *)) {
        [SKAdNetwork registerAppForAdNetworkAttribution];
    }
}

- (void)updateConversionValue:(NSInteger)converionValue {
    if (@available(iOS 14, *)) {
        [SKAdNetwork updateConversionValue:converionValue];
    }
}

//Method builds request url with following parameters. If one of them is nil, returns url without query params.
- (NSURL *)buildRequestURLWithUID:(NSString *)uid appId:(NSString *)appId devKey:(NSString *)devKey {
    NSURLComponents *queryURLComponents = [[NSURLComponents alloc] init];
    
    queryURLComponents.scheme = @"https";
    queryURLComponents.host = @"skadsdkless.appsflyer.com";
    queryURLComponents.path = @"/api/v1.0/conversion-value";
    
    if (uid != nil && appId != nil) {
        NSURLQueryItem *uidItem = [[NSURLQueryItem alloc] initWithName:@"uid" value:uid];
        NSURLQueryItem *appIdItem = [[NSURLQueryItem alloc] initWithName:@"app_id" value:appId];
        queryURLComponents.queryItems = @[appIdItem, uidItem];
    }

    return queryURLComponents.URL;
}

//Returns NSDictionary, which parameters are used as request header fields.
- (NSDictionary *)buidRequestHeadersWithDevKey:(NSString *)devKey appID:(NSString *)appID uid:(NSString *)uid {
    if (!devKey && !appID && !uid) {
        return  nil;
    }
    
    NSTimeInterval currentTimeInSeconds = round([[NSDate date] timeIntervalSince1970]);
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
