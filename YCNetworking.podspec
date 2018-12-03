Pod::Spec.new do |s|
s.name = "YCNetworking"
s.authors = "anyuechao"
s.homepage = "https://github.com/anyuechao/YCNetworking.git"
s.summary = "基于AFNetworking的网络请求封装"
s.version = "1.0.0"
s.platform = :ios, "8.0"
s.source = { :git => "https://github.com/anyuechao/YCNetworking.git", :tag => s.version }
s.requires_arc     = true
s.ios.deployment_target = '8.0'
s.default_subspec = 'Core'
s.resource  = "YCNetworking/Source/Logger/iPhoneTypeDefine.plist"
    s.subspec 'Core' do |core|
        core.source_files = 'YCNetworking/Source/YCNetworking.h', 'YCNetworking/Source/Generator/**/*.{h,m}', 'YCNetworking/Source/Manager/**/*.{h,m}', 'YCNetworking/Source/Engine/**/*.{h,m}', 'YCNetworking/Source/Logger/**/*.{h,m}', 'YCNetworking/Source/Config/**/*.{h,m}'
        core.dependency 'AFNetworking', '~> 3.2.1'
    end
    s.subspec 'Center' do |center|
        center.source_files = 'YCNetworking/Source/Center/*.{h,m}'
        center.dependency 'YCNetworking/Core'
        center.dependency 'YYModel'
    end
end
