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
    pod 'SnapKit', '<= 4.2.0'
    # Then API - initialization
    pod 'Then', '<= 2.4.0'
    # Realm database
    pod 'RealmSwift', '<= 4.4.0'
    # async images
    pod 'SDWebImage', '~> 3.8'
    # Color utilities
    pod 'BSColorUtils', :git => 'https://github.com/SlayterDev/BSColorUtils'
    # UITextView Syntax Highlighting
    pod 'Highlightr', :git => 'https://github.com/raspu/Highlightr.git', :tag => '2.1.0'
    # Event based actions
    pod 'LUAutocompleteView', '<= 3.0.0'
    pod 'GCDWebServer', '~> 3.0'
    pod 'SwiftyStoreKit', '<= 0.14.0'
    pod 'BulletinBoard', '<= 3.0.0'
    pod 'SwiftKeychainWrapper', '<= 3.4.0'

    project 'RadiumBrowser.xcodeproj'

end

target 'RadiumBrowser' do
    all_pods
end
