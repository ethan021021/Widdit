# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'
target 'Widdit' do

pod 'SlackTextViewController'
pod 'CircleSlider', '~> 0.4.0'
pod 'Bolts'
pod 'SnapKit', '~> 0.22.0'
pod 'MBProgressHUD', '~> 0.9.2'
pod 'SimpleAlert'
pod 'IQKeyboardManagerSwift'
pod 'ParseFacebookUtilsV4'
pod 'SinchVerification-Swift'
pod 'ImageViewer'
pod 'Kingfisher', '~> 2.5.0'
pod 'AFImageHelper'
pod 'libPhoneNumber-iOS', '~> 0.8'
pod 'XCGLogger', :git => 'https://github.com/DaveWoodCom/XCGLogger', :branch => 'swift_2.3'
pod 'ALCameraViewController'
pod 'Fusuma', :git => 'https://github.com/ytakzk/Fusuma', :branch => 'swift2.3'
pod 'BetterSegmentedControl', '0.4'
pod 'SevenSwitch', '~> 2.0'
pod 'StatefulViewController'#, :git => 'https://github.com/aschuch/StatefulViewController', :branch => 'swift2.3'
pod 'SDVersion'
pod 'Instabug'
pod 'Whisper'
pod 'RAMAnimatedTabBarController'
pod 'PermissionScope'
pod 'SRKControls', :git => 'https://github.com/lolohouse/SRKControls.git'
pod 'SkyFloatingLabelTextField'
pod 'Presentr', :git => 'https://github.com/icalialabs/Presentr.git', :tag => '0.2.1'
pod 'MBTwitterScroll'
pod 'Localytics', '~> 4.0'
pod 'DGActivityIndicatorView'
pod 'Device'
pod 'Onboard'
pod 'NoChat', :git => 'https://github.com/little2s/NoChat', :branch => 'swift2_3'
pod 'NoChatTG', :git => 'https://github.com/little2s/NoChat', :branch => 'swift2_3'
pod 'ActiveLabel', :git => 'https://github.com/optonaut/ActiveLabel.swift', :branch => 'swift-2.3'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end

end
