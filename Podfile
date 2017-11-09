source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

pre_install do |installer|
    # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
    def installer.verify_no_static_framework_transitive_dependencies; end
end

def all_pods
    # See "Shared" folder for more shared libraries/resources

    # AutoLayout
    pod 'SnapKit', '<= 3.2.0'
    # Then API - initialization
    pod 'Then'
    # Realm database
    pod 'RealmSwift', '<= 2.10.0'
    # async images
    pod 'SDWebImage', '~> 3.8'
    # Color utilities
    pod 'BSColorUtils', :git => 'https://github.com/SlayterDev/BSColorUtils'
    # UITextView Syntax Highlighting
    pod 'Highlightr', :git => 'https://github.com/raspu/Highlightr.git'
    # Event based actions
    pod 'WaitForIt'
    pod 'LUAutocompleteView'
    pod 'GCDWebServer', '~> 3.0'
    pod 'SwiftyStoreKit'
    pod 'BulletinBoard'
    pod 'SwiftKeychainWrapper'
    pod 'Fabric'
    pod 'Crashlytics'

    project 'RadiumBrowser.xcodeproj'

end

post_install do |installer|
    # Your list of targets here.
    myTargets = ['Highlightr', 'SnapKit']
    
    installer.pods_project.targets.each do |target|
        if myTargets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end

target 'RadiumBrowser' do
    all_pods
end
