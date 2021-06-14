

Pod::Spec.new do |spec|
  spec.name         = "MomagiciOSSDK"
  spec.version      = "0.0.1"
  spec.summary      = "MoMagic Notification push services"
  spec.description  = " MoMagic Push Notifications To Drive Audience Engagement"
  spec.homepage     = "https://github.com/izooto-mobile-sdk/iOSSDK"
  spec.license      = "MIT"
   spec.author      = { "AmitKumarGupta" => "amit@datability.co" }
  spec.platform     = :ios,"10"
  spec.swift_version = '4.0'
  spec.source       = { :git =>"https://github.com/izooto-mobile-sdk/iOSSDK.git", :tag => "0.0.1" }
  spec.source_files  = 'MomagiciOSSDK/**/*.{h,swift}'
  spec.exclude_files = 'MomagiciOSSDK/**/*.plist'
  spec.requires_arc  = true
  
end
