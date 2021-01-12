#
# Be sure to run `pod lib lint AppsFlyerSDKLessSKAdNetworkClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppsFlyerSDKLessSKAdNetworkClient'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AppsFlyerSDKLessSKAdNetworkClient.'
  s.description      = 'iOS SDKLess + Sample App which demonstrates the usage of Appsflyer API - SKAdNetwork S2S get conversion value per user'
  s.homepage         = 'https://github.com/Ivan/AppsFlyerSDKLessSKAdNetworkClient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ivan' => 'ivan.obodovskyi@appsflyer.com' }
  s.source           = { :git => 'https://github.com/AppsFlyerSDK/appsflyer-sdkless-skadnetwork-client.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'AppsFlyerSDKLessSKAdNetworkClient/Classes/**/*'

end
