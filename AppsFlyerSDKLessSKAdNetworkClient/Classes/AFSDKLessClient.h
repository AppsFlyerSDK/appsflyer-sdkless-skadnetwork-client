//
//  AFSDKLessClient.h
//  AppsFlyerSDKLessSKAdNetworkClient
//
//  Created by Ivan Obodovskyi on 02.11.2020.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFSDKLessClient : NSObject

@property (class, nonatomic, readonly) AFSDKLessClient *shared;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)new NS_UNAVAILABLE;

- (void)registerForAdNetworkAttribution;
- (void)updateConversionValue:(NSInteger)converionValue;
- (void)requestConversionValueWithUID:(NSString *)clientID devKey:(NSString *)devKey
                                appID:(NSString *)appID
                      completionBlock:(void (^)(NSNumber * _Nullable result, NSError * _Nullable error))completionBlock;

@end
NS_ASSUME_NONNULL_END
