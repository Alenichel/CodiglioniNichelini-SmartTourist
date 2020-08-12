# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'SmartTourist' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SmartTourist
  pod 'Katana', '~> 3.2.0'
  pod 'Tempura'
  pod 'PinLayout'
  pod 'FlexLayout'
  pod 'DeepDiff'
  pod 'Cosmos', '~> 20.0'
  pod 'Fuse', :git => 'https://github.com/fabiocody/fuse-swift'
  pod 'Alamofire', '~> 5.0.0-rc.3'
  pod 'ImageSlideshow', '~> 1.8.3'
  pod 'MarqueeLabel'
  pod 'SigmaSwiftStatistics', '~> 9.0'
  pod 'FontAwesome.swift'
  pod "SwiftyXMLParser", :git => 'https://github.com/fabiocody/SwiftyXMLParser.git'
  pod 'FlagKit'
  
  target 'SmartTouristTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'TempuraTesting'
  end

end

target 'PictureNotification' do
  use_frameworks!
  pod 'PinLayout'
end

target 'SmartTouristAppleWatch Extension' do
  platform :watchos, '6.0'
  use_frameworks!
  pod 'Alamofire', '~> 5.0.0-rc.3'
  pod 'HydraAsync'
  pod 'Fuse', :git => 'https://github.com/fabiocody/fuse-swift'
  pod "SwiftyXMLParser", :git => 'https://github.com/fabiocody/SwiftyXMLParser.git'
end
