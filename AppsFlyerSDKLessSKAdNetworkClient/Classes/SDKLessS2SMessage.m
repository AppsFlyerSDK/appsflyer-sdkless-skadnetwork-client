//
//  SDKLessS2SMessage.m
//  AppsFlyerSKAdNetworkSDKLessClient
//
//  Created by ivan.obodovskyi on 20.04.2023.
//

#import "SDKLessS2SMessage.h"
#import <dlfcn.h>

const char *coarseValueHigh = "SKAdNetworkCoarseConversionValueHigh";
const char *coarseValueMedium = "SKAdNetworkCoarseConversionValueMedium";
const char *coarseValueLow = "SKAdNetworkCoarseConversionValueLow";

static const NSString *conversionValueKey = @"value";
static const NSString *seqIndexKey = @"postback_sequence_index";
static const NSString *coarseValueKey = @"coarse_value";
static const NSString *nextWTimeKey = @"next_w_time";
static const NSString *lockWindowKey = @"lock";
static const NSString *messageKey = @"message";

@implementation SDKLessS2SMessage

- (instancetype)initWithMessage:(NSDictionary *)message {
    self = [super init];
    if (self) {
        
        if ([message[conversionValueKey] respondsToSelector:@selector(intValue)]) {
            _conversionValue = [message[conversionValueKey] intValue];
        }
        
        if ([message[seqIndexKey] respondsToSelector:@selector(intValue)]) {
            _postbackSequenceIndex = [message[seqIndexKey] intValue];
        }
        
        if ([message[coarseValueKey] respondsToSelector:@selector(isEqualToString:)]) {
            _coarseValue = message[coarseValueKey];
        }
        
        if ([message[nextWTimeKey] respondsToSelector:@selector(doubleValue)]) {
            _nextWindowTime = [message[nextWTimeKey] doubleValue];
        }
        
        if ([message[lockWindowKey] respondsToSelector:@selector(boolValue)]) {
            _lockWindow = [message[lockWindowKey] boolValue];
        }
        
        if ([message[messageKey] respondsToSelector:@selector(isEqualToString:)]) {
            _message = message[messageKey];
        }
        
    }
    return self;
}

- (NSString * __nullable)getCoarseValueRepresentation {
    if (@available(iOS 16.1.1, macCatalyst 16.1.1, *)) {
        // We should not call Apple API in case we have coarseValue `nil` in the 2 and 3 windows.

        if (_coarseValue != nil &&
            _coarseValue.length != 0
            && _postbackSequenceIndex > 0) {
            return nil;
        }
        
        if  ([_coarseValue isEqualToString:@"high"]) {
            NSString * __autoreleasing *coarseValHigh = (NSString * __autoreleasing *)dlsym(RTLD_DEFAULT, coarseValueHigh);
            return *coarseValHigh;
        }
        
        if ([_coarseValue isEqualToString:@"medium"]) {
            NSString * __autoreleasing *coarseValMedium = (NSString * __autoreleasing *)dlsym(RTLD_DEFAULT, coarseValueMedium);
            return *coarseValMedium;
        }
        
        // In the first conversion window we are not allowed to return `nil` Edge case coverage, because
        // for SKAN 4 first conversion window backend should always return `low`.
        // https://www.notion.so/appsflyerrnd/SDK-Integration-c4022ebde7164acaa759b6377ecae8aa#e1b1a359b2dc483d80b1f06e72c3522a
        NSString * __autoreleasing *coarseValLow = (NSString * __autoreleasing *)dlsym(RTLD_DEFAULT, coarseValueLow);
        return *coarseValLow;
    }
    // `_coarseValue` nil or iOSVersion is lower than 16.1.1
    // We do not want to pass `nil` to the Apple API, that is why we set the default string value,
    // it will be omitted by the system for SKAD 4 Apple API and not called in implementations for the older API.
    return @"low";
}

- (AFSDKSKANMode)configMode {
    return (_postbackSequenceIndex > 0 || _nextWindowTime > 0) ? AFSDKSKANModeV4 : AFSDKSKANModeDefault;
}

- (BOOL)shouldStopS2STimer {
    if (@available(iOS 16.1.1, macCatalyst 16.1.1, *)) {
        return _lockWindow;
        //||       (_postbackSequenceIndex == 2 && _nextWindowTime == 0);
    }
    // iOS less than 16.1.1 means, that we have skan S2S config less than v4,
    // in that case we do not stop the conversion timer.
    return false;
}

- (NSString *)stringifiedRepresentation {
    return [NSString stringWithFormat:@"%d;%@;%d;%d;%.f", _conversionValue, _coarseValue, _lockWindow, _postbackSequenceIndex, _nextWindowTime];
}



@end
