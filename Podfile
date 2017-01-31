source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
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

    project 'RadiumBrowser.xcodeproj'

end

target 'RadiumBrowser' do
    all_pods
end

target 'RadiumBrowserTests' do
    all_pods
end

target 'RadiumBrowserUITests' do
    all_pods
end
