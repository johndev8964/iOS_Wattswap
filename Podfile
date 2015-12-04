# Uncomment this line to define a global platform for your project
# platform :ios, “7.1”

source 'https://github.com/CocoaPods/Specs.git'

target :Wattswap do

pod 'MBProgressHUD', '~> 0.8'
pod 'SVProgressHUD'
pod 'AFNetworking', '~> 2.0'
pod 'AFNetworking+ImageActivityIndicator', '~> 1.0'
pod 'Toast','~> 2.4'
pod 'Dropbox-iOS-SDK'
pod 'TPKeyboardAvoiding', '~> 1.2'
pod 'MFSideMenu', '~> 0.5'
pod 'M13Checkbox', '~> 1.1'
pod 'IQKeyboardManager'

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end

end



