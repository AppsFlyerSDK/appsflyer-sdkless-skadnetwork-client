//
//  AFSDKLessClient.h
//  AppsFlyerSDKLessSKAdNetworkClient
//
//  Created by Ivan Obodovskyi on 02.11.2020.
//


#import <AppsFlyerSKAdNetworkSDKLessClient/SDKLessS2SMessage.h>
#import <StoreKit/SKAdNetwork.h>

NS_ASSUME_NONNULL_BEGIN


@interface AppsFlyerSKAdNetworkSDKLessClient : NSObject

@property (class, nonatomic, readonly) AppsFlyerSKAdNetworkSDKLessClient *shared;
- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype)new NS_UNAVAILABLE;

/*!
    @brief AFSDKLessClient wrapper for `[SKAdNetwork registerForAdNetworkAttribution]`
    @discussion See the doc: https://developer.apple.com/documentation/storekit/skadnetwork/2943654-registerappforadnetworkattributi?language=objc
 */
- (void)registerForAdNetworkAttribution;

/*!
    @brief AFSDKLessClient wrapper for `[SKAdNetwork updateConversionPostbackConversionValue:] methods`
    @param conversionValue  conversion value to update.
 
    @discussion See the doc: https://developer.apple.com/documentation/storekit/skadnetwork
 */
- (void)updateConversionValue:(NSInteger)conversionValue;

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^)(NSError * _Nullable error))completionHandler;

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                          coarseValue:(SKAdNetworkCoarseConversionValue)coarseValue
                    completionHandler:(void (^)(NSError * _Nullable error))completionHandler  API_AVAILABLE(ios(16.0));

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                          coarseValue:(SKAdNetworkCoarseConversionValue)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^)(NSError * _Nullable error))completionHandler  API_AVAILABLE(ios(16.0));

/*!
    @brief Perform request for conversion value using Vendor Identifier instead of
    client ID in the request.
    
    @param devKey your AppsFlyer devKey.
    @param appID  iTunes appID.
    @param completionHandler returns result as an NSNumber value or NSError.
    
 */
- (void)requestConversionValueWithDevKey:(NSString *)devKey
                                   appID:(NSString *)appID
                       completionHandler:(void (^)(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error))completionHandler;

/*!
    @param devKey your AppsFlyer devKey.
    @param appID  iTunes appID
    @param clientID AppsFlyer ID can be retrieved in AppsFlyerLib using command: [[AppsFlyerLib shared] getAppsFlyerUID]
    @param completionBlock returns result as an NSNumber value or NSError.
 */
- (void)requestConversionValueWithUID:(NSString *)clientID devKey:(NSString *)devKey
                                appID:(NSString *)appID
                      completionBlock:(void (^)(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error))completionBlock;


@end
NS_ASSUME_NONNULL_END
