# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'zorro-ios-app11' do
  # Comment the next line if you don't want to use dynamic frameworks
  # TO-DO: I commented this line in order to allow build Zorro iOS app in iOS 13.3.1, as it crash with Free Dev Accounts based on:
  #   https://github.com/Alamofire/Alamofire/issues/3051
  #
  #use_frameworks!
  
  pod 'IPImage'
  pod "InitialsImageView"
  pod 'Alamofire', '~> 5.1'
  pod 'DeviceKit', '~> 2.0'
  pod 'SwiftGifOrigin', '~> 1.7.0'
  pod 'SwiftyJSON', '~> 4.0'
  pod 'RadioGroup'
  pod 'Floaty', '~> 4.2.0'
  pod 'Kingfisher', '~> 5.0'
  pod 'ImageViewer.swift', '~> 3.0'
  pod 'ImageViewer.swift/Fetcher', '~> 3.0'
  pod 'MaterialComponents/NavigationDrawer'
  pod 'MaterialComponents/List'
  pod 'MaterialComponents/Snackbar'
  pod 'Lightbox'
  pod 'TKFormTextField'
  
  # Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  
  # Add the pod for Firebase Cloud Messaging
  pod 'Firebase/Messaging'
  
  pod 'GoogleMaps', '4.1.0'
  
  # pod 'SPAlert'
  # pod 'RadioGroup', '~> 1.4.0'
  
  # Pods for zorro-ios-app11

  target 'zorro-ios-app11Tests' do
    inherit! :search_paths
    # Pods for  testing
  end

  target 'zorro-ios-app11UITests' do
    # Pods for testing
  end

end
