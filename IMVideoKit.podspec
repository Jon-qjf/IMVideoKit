#
# Be sure to run `pod lib lint IMVideoKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'IMVideoKit'
s.version          = '1.0'
s.summary          = 'A short description of IMVideoKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'https://github.com/Jon-qjf/IMVideoKit'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'qjf' => 'feng474425527@163.com' }
s.source           = { :git => 'https://github.com/Jon-qjf/IMVideoKit.git', :tag => s.version.to_s }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
s.ios.deployment_target = '8.0'
s.source_files = 'IMVideoKit/Classes/**/*'
#支持swift并指定版本
s.swift_version = '5.0'
#s.libraries = "c++"
#支持framework
s.static_framework = true

#打包项目引用的资源
s.resource_bundles = {
'IMVideoKitImages' => ['IMVideoKit/Assets/**/*.png']
}
#获取自己打包的framework库
#指定文件位置 引用framework
s.ios.vendored_frameworks = 'IMVideoKit/Framework/*.framework'
#引用framework
s.vendored_frameworks = 'ImSDK.framework'
#引用本地的第三方静态库
s.vendored_libraries = 'IMVideoKit/Classes/Third/voiceConvert/**/*.a'
#设置私有文件,不对外暴露,不会自动被umbrella引用,wav文件是c++的音频处理文件,需要引用两个.a库.libopencore-amrnb.a和libopencore-amrwb.a.如果对外引用的话就需要在主工程里添加这两个库才能使用
s.private_header_files = 'IMVideoKit/Classes/Third/voiceConvert/amrwapper/*.h'

# 解决pod spec lint报错
# Ld /Users/User/Library/Developer/Xcode/DerivedData/App-diabdhyizxcjrdgsmhdefdvgroxa/Build/Intermediates.noindex/App.build/Release-iphonesimulator/App.build/Objects-normal/arm64/Binary/App normal arm64
s.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64', }
#支持的系统静态库
s.libraries = 'stdc++','c++'
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  s.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64'
  }
  s.requires_arc = true


s.frameworks   = 'AVFoundation', 'Foundation','UIKit'
s.dependency 'MMLayout', '~> 0.2.0'
s.dependency 'SDWebImage'
s.dependency 'ReactiveObjC'
s.dependency 'Toast'
s.dependency 'TXLiteAVSDK_TRTC'
s.dependency 'TZImagePickerController'
s.dependency 'YYImage'
s.dependency 'YBImageBrowser'
s.dependency 'ISVImageScrollView', '~> 0.1.2'

##################################################################################
#s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
#s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
#s.library = 'c++'
#s.xcconfig = {
#   'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
#   'CLANG_CXX_LIBRARY' => 'libc++'
#}
#s.xcconfig = {
#     'IPHONEOS_DEPLOYMENT_TARGET' => '10.0'
# }
# s.public_header_files = 'Pod/Classes/**/*.h'
#s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }
##################################################################################








end
