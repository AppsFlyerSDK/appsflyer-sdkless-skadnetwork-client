//
//  AFAppDelegate.m
//  AppsFlyerSDKLessSKAdNetworkClient
//
//  Created by Ivan on 11/02/2020.
//  Copyright (c) 2020 Ivan. All rights reserved.
//

#import "AppDelegate.h"
#import <AppsFlyerSKAdNetworkSDKLessClient/AppsFlyerSKAdNetworkSDKLessClient.h>
#import <BackgroundTasks/BackgroundTasks.h>

@implementation AppDelegate
NSString *uid = @"YOUR_UNIQUE_ID";
NSString *appId = @"YOUR_APP_ID"; //ID - is a string with following format @"id888707074"
NSString *devKey = @"YOUR_DEV_KEY";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[AppsFlyerSKAdNetworkSDKLessClient shared] registerForAdNetworkAttribution];
    
    if ([self isDailyUpdateConversionWindowExpired]) {
        [[AppsFlyerSKAdNetworkSDKLessClient shared] requestConversionValueWithUID:uid devKey:devKey appID:appId completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
            }
            
            if (result) {
                [self updateSKANConversionWith:result];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kSDKLessWindow"];
            }
        }];
    }
    
    if (@available(iOS 13, *)) {
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"scheduleEventAF" usingQueue: dispatch_get_main_queue() launchHandler:^(__kindof BGTask * _Nonnull task) {
            [self handleAppRefreshWith:task];
        }];
    }
    
    if (@available(iOS 13, *)) {
        [self scheduleAppRefresh];
    }
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval: 3600 * 8];
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if ([self isDailyUpdateConversionWindowExpired]) {
        [[AppsFlyerSKAdNetworkSDKLessClient shared] requestConversionValueWithUID:uid devKey:devKey appID:appId completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
            if (result) {
                [self updateSKANConversionWith:result];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kSDKLessWindow"];
                completionHandler(UIBackgroundFetchResultNewData);
            } else {
                completionHandler(UIBackgroundFetchResultNoData);
            }
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (@available(iOS 13, *)) {
        [self scheduleAppRefresh];
    }
}


- (void)handleAppRefreshWith:(BGTask *)task  API_AVAILABLE(ios(13.0)){
    [self scheduleAppRefresh];
    
    NSOperation *operation = [[NSOperation alloc] init];
    
    [task setExpirationHandler:^{
        NSLog(@"Task expired");
    }];
    
    void (^completionBlock)(void) = ^{
        if ([self isDailyUpdateConversionWindowExpired]) {
            [[AppsFlyerSKAdNetworkSDKLessClient shared] requestConversionValueWithUID:uid devKey:devKey appID:appId completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
                if (result) {
                    [self updateSKANConversionWith:result];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kSDKLessWindow"];
                    [task setTaskCompletedWithSuccess:YES];
                } else {
                    [task setTaskCompletedWithSuccess:NO];
                }
            }];
        }
    };
    
    [operation setCompletionBlock:completionBlock];
    
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)scheduleAppRefresh {
    if (@available(iOS 13.0, *)) {
        BGAppRefreshTaskRequest *taskRequest = [[BGAppRefreshTaskRequest alloc] initWithIdentifier:@"scheduleEventAF"];
        NSError *error;
        [taskRequest setEarliestBeginDate:[NSDate dateWithTimeIntervalSinceNow:3600 * 8]];
        [[BGTaskScheduler sharedScheduler] submitTaskRequest:taskRequest error:&error];
    } else {
        return;
    }
}

- (BOOL)isDailyUpdateConversionWindowExpired {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSDKLessWindow"];
    // If there is no "kSDKLessWindow" value in UserDefaults, return true.
    if (date == nil) {
        return YES;
    }
    NSInteger diff = [[[NSCalendar currentCalendar] components:(NSCalendarUnitHour) fromDate:date toDate:[NSDate date] options:kNilOptions] hour];
    //If difference between current time and stored 'kSDKLessWindow' is more than 24 hours, return true.
    return diff > 24;
}

// This method contains all available SKAN upcv API usage examples.
// Please, choose one, depending on your expected postback version + iOS version, according to the Apple SKAdNetwork doc
// These methods are basically SKAdNetwork API wrappers, you can call Apple API directly.
- (void)updateSKANConversionWith:(SDKLessS2SMessage*)message {
    // Example for iOS 16.1 version may also contain `lockWindow` parameter
    [[AppsFlyerSKAdNetworkSDKLessClient shared] updatePostbackConversionValue:message.conversionValue coarseValue:[message getCoarseValueRepresentation] completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // Example for iOS 15.5 version
    [[AppsFlyerSKAdNetworkSDKLessClient shared] updatePostbackConversionValue:message.conversionValue completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];

    // Example for iOS 11.3 and higher
    [[AppsFlyerSKAdNetworkSDKLessClient shared] updateConversionValue:message.conversionValue];
}

@end
