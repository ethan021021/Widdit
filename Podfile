# Uncomment this line to define a global platform for your project
# platform :ios, '8.0'
# Uncomment this line if you're using Swift
use_frameworks!

target 'Widdit' do

pod 'SlackTextViewController'
pod 'CircleSlider'
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
pod 'XCGLogger', '~> 3.3'
pod 'ALCameraViewController'
pod 'Whisper'
pod 'RAMAnimatedTabBarController'
pod 'StatefulViewController'
pod 'PermissionScope'
pod 'SRKControls'
pod 'SkyFloatingLabelTextField'

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end

end

