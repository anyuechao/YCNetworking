Pod::Spec.new do |spec|
  spec.name             = 'YCNetworking'
  spec.version          = '1.0.0'
  spec.homepage         = 'https://github.com/anyuechao/YCNetworking'
  spec.authors          = "anyuechao"
  spec.summary          = '基于AFNetworking的网络请求封装'
  spec.source           =  {
      :git => 'https://github.com/anyuechao/YCNetworking.git',
      :tag => spec.version,
      :submodules => true
   }
  spec.requires_arc     = true
  spec.ios.deployment_target = '8.0'
  spec.default_subspec = 'Core'
  spec.resource  = "YCNetworking/Source/Logger/iPhoneTypeDefine.plist"

  spec.subspec 'Core' do |core|
    core.source_files = 'YCNetworking/Source/YCNetworking.h', 'YCNetworking/Source/Generator/**/*.{h,m}', 'YCNetworking/Source/Manager/**/*.{h,m}', 'YCNetworking/Source/Engine/**/*.{h,m}', 'YCNetworking/Source/Logger/**/*.{h,m}', 'YCNetworking/Source/Config/**/*.{h,m}'
    core.dependency 'AFNetworking', '~> 3.2.1'
  end

  spec.subspec 'Center' do |center|
    center.source_files = 'YCNetworking/Source/Center/*.{h,m}'
    center.dependency 'YCNetworking/Core'
    center.dependency 'YYModel'
  end
end
