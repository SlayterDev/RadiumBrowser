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
    pod 'SnapKit'
    # Then API - initialization
    pod 'Then'
    # Realm database
    pod 'RealmSwift'
    # async images
    pod 'SDWebImage', '~> 3.8'
    # Color utilities
    pod 'BSColorUtils', :git => 'https://github.com/SlayterDev/BSColorUtils'
    # UITextView Syntax Highlighting
    pod 'Highlightr', :git => 'https://github.com/raspu/Highlightr.git'
    # Event based actions
    pod 'LUAutocompleteView'
    pod 'GCDWebServer', '~> 3.0'
    pod 'SwiftyStoreKit'
    pod 'BulletinBoard'
    pod 'SwiftKeychainWrapper'

    project 'RadiumBrowser.xcodeproj'

end

target 'RadiumBrowser' do
    all_pods
end
