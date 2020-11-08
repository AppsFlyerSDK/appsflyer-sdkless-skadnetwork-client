

<img src="https://www.appsflyer.com/wp-content/uploads/2016/11/logo-1.svg"  width="450">

# appsflyer-sdkless-skadnetwork-client


iOS SDKLess + Sample App which demonstrates the usage of Appsflyer API - *SKAdNetwork S2S get conversion value per user*

The repository has 2 parts:
 - The [AppsFlyerSDKLessSKAdNetworkClient](https://github.com/AppsFlyerSDK/appsflyer-sdkless-skadnetwork-client/tree/main/AppsFlyerSDKLessSKAdNetworkClient/Classes) - SDKLess code (Obj-C)
 - The Sample App ([Obj-C](https://github.com/AppsFlyerSDK/appsflyer-sdkless-skadnetwork-client/tree/main/Example/AppsFlyerSDKLessSKAdNetworkClient) + [Swift](https://github.com/AppsFlyerSDK/appsflyer-sdkless-skadnetwork-client/tree/main/Example/AppsFlyerSDKLessSKAdNetworkClient_Example-Swift))

### SPEC

Call the SK API with **GET** request that has the following query params:

`uid` - appsflyer id
`app_id` - application id
`af_timestamp` - current time in seconds
`af_sig` - Create an HMAC SHA256 signature by concatenating the values of the timestamp, dev key, app id, and AppsFlyer id:

`HmacSHA256(af_timestamp + DevKey + app_id + uid)`

app_id in a format - `"idxxxxxxx"`
The HMAC is generated using SHA256 and uses the DevKey as the signature’s secret key. The account Dev Key is taken from the App Settings page in the AppsFlyer dashboard.

##### Example:
```
https://skadsdkless.appsflyer.com/api/v1.0/converison-value?uid=LYPnL-sdJuSwjg-AQ2GTZehc&app_id=123456789&af_sig=b457aca5d23a6cbe512775578201&af_timestamp=1603034622
```
SK API will return the following *conversion value* response as JSON:
```
{
  "value": 43
}
```




##### Response codes

*200* - the conversion value
*400* - invalid request (params or headers missing or malformed)
*401* - invalid signature
*404* - uid not found/expired
*503* - server busy  


### How to run the Sample App

(Be sure you run Xcode 12+)

```
$ cd Example
$ pod install
```

#### Dependencies
- AppsFlyerSDKLessSKAdNetworkClient
- OCMock - *for testing*
- OHHTTPStubs - *for testing*

### API and Usage

```swift
  private let uid = "YOUR_APPSFLYER_ID"; //AppsFlyerLib.shared().getAppsFlyerUID()
  private let appId = "YOUR_APP_ID"; //ID - is a string with following format @"idXXXXXXXX"
  private let devKey = "YOUR_DEV_KEY";
    
  AFSDKLessClient.shared.requestConversionValue(withUID: self.uid, devKey: self.devKey, appID: self.appId) { (cv, error) in
     if let cv = cv?.intValue {
          // Tells to the Client to register For AdNetwork Attribution (iOS 11.3+)
          // Should be called only once
          AFSDKLessClient.shared.registerForAdNetworkAttribution()  
          
          // Tells to the Client to update conversion value 
          AFSDKLessClient.shared.updateConversionValue(cv)        
          task.setTaskCompleted(success: true)
      } else {
          task.setTaskCompleted(success: false)
      }                        
  }
```
