//
//  SDKLessS2SMessage.h
//  AppsFlyerSKAdNetworkSDKLessClient
//
//  Created by ivan.obodovskyi on 20.04.2023.
//

#import <Foundation/Foundation.h>
#import <StoreKit/SKAdNetwork.h>


typedef enum AFSDKSKANMode: NSUInteger {
    AFSDKSKANModeDefault,
    AFSDKSKANModeV4
} AFSDKSKANMode;

@interface SDKLessS2SMessage : NSObject

@property (nonatomic, readonly, strong, nullable) NSString *coarseValue;
@property (nonatomic, readonly, strong, nullable) NSString *message;
@property (nonatomic, readonly, assign) int conversionValue;
@property (nonatomic, readonly, assign) int postbackSequenceIndex;
@property (nonatomic, readonly, assign) BOOL lockWindow;
@property (nonatomic, readonly, assign) NSTimeInterval nextWindowTime;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithMessage:(NSDictionary *)message NS_DESIGNATED_INITIALIZER;

- (NSString * __nullable)getCoarseValueRepresentation;
- (BOOL)shouldStopS2STimer;
- (NSString *)stringifiedRepresentation;
- (AFSDKSKANMode)configMode;

@end
