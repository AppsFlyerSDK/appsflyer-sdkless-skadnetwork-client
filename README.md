

<img src="https://www.appsflyer.com/wp-content/uploads/2016/11/logo-1.svg"  width="450">

# appsflyer-sdkless-skadnetwork-client


iOS SDKLess framework and Sample App in the workspace demonstrate the usage of Appsflyer API - *SKAdNetwork S2S get conversion value per user*

### SPEC

Call the SK API with **GET** request that has the following query params:

Key    |   Description
---            |   ---
`uid`          |   appsflyer id
`app_id`       |   application id
`sdk_version`  |   sdk or framework version for the request
`af_timestamp` |   current time in miliseconds
`af_sig`       |   Create an HMAC SHA256 signature by concatenating the values of the timestamp, dev key, app id, and AppsFlyer id: `HmacSHA256(af_timestamp + app_id + uid)`


app_id in a format - `"idxxxxxxx"`
The HMAC is generated using SHA256 and uses the `DevKey` as the signature secret key. The account Dev Key is taken from the App Settings page in the AppsFlyer dashboard.

##### Example 1:
```
https://skadsdkless.appsflyer.com/api/v1.0/conversion-value?uid=LYPnL-sdJuSwjg-AQ2GTZehc&app_id=123456789&af_sig=b457aca5d23a6cbe512775578201&af_timestamp=1603034622
```
SK API will return the following *conversion value* response as JSON:
```
{
  "value": 43
}
```

##### Example 2:
```
https://skadsdkless.appsflyer.com/api/v2.0/conversion-value?uid=LYPnL-sdJuSwjg-AQ2GTZehc&app_id=123456789&sdk_version=sdk_less&af_sig=b457aca5d23a6cbe512775578201&af_timestamp=1603034622
```
SK API will return the following *conversion value* response as JSON:
```
{
  "value": 63,
  "coarse_value": "high",
  "lock": YES,
  "next_w_time": 1672147423,
  "postback_sequence_index": 2
}
```

##### Response codes

Code    |   Description
---     |   ---
200     |   the conversion value
400     |   invalid request (params or headers missing or malformed)
401     |   invalid signature
404     |   uid not found/expired
503     |   server busy  


### How to run the Sample Apps

```
$ cd Example
$ pod install 
```

Just open `AppsFlyerSDKLessSKAdNetworkClient.xcworkspace` file, build the framework target and launch sample app.

#### Dependencies
- AppsFlyerSDKLessSKAdNetworkClient
- OCMock - *for testing*
- OHHTTPStubs - *for testing*

## API and Usage Swift:

```swift
  private let uid = "YOUR_APPSFLYER_ID"; //AppsFlyerLib.shared().getAppsFlyerUID()
  private let appId = "YOUR_APP_ID"; //ID - is a string with following format @"idXXXXXXXX"
  private let devKey = "YOUR_DEV_KEY";
    
AFSDKLessClient.shared.requestConversionValue(withUID: self.uid, devKey: self.devKey, appID: self.appId) { (result, error) in
    if error != nil {
        print(error?.localizedDescription)
    }
    
    if let result = result {
        if #available(iOS 13.0, *) {
            self.updateSKANConversion(with: result)
        }
    }
}

// This method contains all available SKAN upcv API usage examples.
// Please, choose one, depending on your expected postback version + iOS version, according to the Apple SKAdNetwork doc
// These methods are basically SKAdNetwork API wrappers, you can call Apple API directly.
func updateSKANConversion(with message: SDKLessS2SMessage) {
    // Example for iOS 16.1 version may also contain `lockWindow` parameter
    if #available(iOS 16.1.1, *) {
        AFSDKLessClient.shared.updatePostbackConversionValue(Int(message.conversionValue), coarseValue: message.getCoarseValueRepresentation()) { skanErr in
            print("SKAN Err: \(skanErr?.localizedDescription)")
        }
    }


    if #available(iOS 15.4, *) {
        AFSDKLessClient.shared.updatePostbackConversionValue(Int(message.conversionValue)) { skanErr in
            print("SKAN Err: \(skanErr?.localizedDescription)")
        }
    }


    // Example for iOS 11.3 and higher
    AFSDKLessClient.shared.updateConversionValue(Int(message.conversionValue))
}
```
## API and Usage ObjC:
```objc
NSString *uid = @"YOUR_UNIQUE_ID";
NSString *appId = @"YOUR_APP_ID"; //ID - is a string with following format @"id888707074"
NSString *devKey = @"YOUR_DEV_KEY";

[[AFSDKLessClient shared] requestConversionValueWithUID:uid devKey:devKey appID:appId completionBlock:^(SDKLessS2SMessage * _Nullable result, NSError * _Nullable error) {
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    
    if (result) {
        [self updateSKANConversionWith:result];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kSDKLessWindow"];
    }
}];

// This method contains all available SKAN upcv API usage examples.
// Please, choose one, depending on your expected postback version + iOS version, according to the Apple SKAdNetwork doc
// These methods are basically SKAdNetwork API wrappers, you can call Apple API directly.
- (void)updateSKANConversionWith:(SDKLessS2SMessage*)message {
    // Example for iOS 16.1 version may also contain `lockWindow` parameter
    [[AFSDKLessClient shared] updatePostbackConversionValue:message.conversionValue coarseValue:[message getCoarseValueRepresentation] completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
    
    // Example for iOS 15.5 version
    [[AFSDKLessClient shared] updatePostbackConversionValue:message.conversionValue completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];

    // Example for iOS 11.3 and higher
    [[AFSDKLessClient shared] updateConversionValue:message.conversionValue];
}
```
