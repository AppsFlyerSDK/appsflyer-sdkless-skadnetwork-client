//
//  AFAppDelegate.m
//  AppsFlyerSDKLessSKAdNetworkClient
//
//  Created by Ivan on 11/02/2020.
//  Copyright (c) 2020 Ivan. All rights reserved.
//

#import "AFAppDelegate.h"
#import <AFSDKLessClient.h>
#import <BackgroundTasks/BackgroundTasks.h>

@implementation AFAppDelegate
NSString *uid = @"YOUR_APPSFLYER_ID"; //[[AppsFlyerLib shared] getAppsFlyerUID]
NSString *appId = @"YOUR_APP_ID"; //ID - is a string with following format @"id888707074"
NSString *devKey = @"YOUR_DEV_KEY";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (@available(iOS 13, *)) {
        // Test with `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"scheduleEventAF"]`
        [[BGTaskScheduler sharedScheduler] registerForTaskWithIdentifier:@"scheduleEventAF" usingQueue:dispatch_get_main_queue() launchHandler:^(__kindof BGTask * _Nonnull task) {
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
    [[AFSDKLessClient shared] requestConversionValueWithUID:uid devKey:devKey appID:appId completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
        NSInteger conversion = [result intValue];
        if (conversion) {
            [[AFSDKLessClient shared] registerForAdNetworkAttribution];
            [[AFSDKLessClient shared] updateConversionValue:conversion];
            completionHandler(UIBackgroundFetchResultNewData);
        } else {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }];
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
        [[AFSDKLessClient shared] requestConversionValueWithUID:uid devKey:devKey appID:appId completionBlock:^(NSNumber * _Nullable result, NSError * _Nullable error) {
            NSInteger conversion = [result intValue];
            if (conversion) {
                [[AFSDKLessClient shared] registerForAdNetworkAttribution];
                [[AFSDKLessClient shared] updateConversionValue:conversion];
                [task setTaskCompletedWithSuccess:YES];
            } else {
                [task setTaskCompletedWithSuccess:NO];
            }
        }];
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

@end
