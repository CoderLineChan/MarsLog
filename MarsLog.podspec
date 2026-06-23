Pod::Spec.new do |s|
  s.name             = 'MarsLog'
  s.version          = '1.0.6-beta.2'
  s.summary          = 'Swift-style declarative UIKit Plus'
  s.homepage         = 'https://github.com/CoderLineChan/MarsLog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'lianchen551@163.com' }
  s.source           = { :git => 'https://github.com/CoderLineChan/MarsLog.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '11.0'
  s.requires_arc = true

  s.source_files = 'MarsLog/**/*.{h,m,mm}'
  s.public_header_files = 'MarsLog/**/*.h'

  s.vendored_frameworks = 'mars.xcframework'
  
  s.libraries = 'c++', 'z'
  s.frameworks = 'Foundation'
  
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '$(inherited) ' +
    '"${PODS_ROOT}/MarsLog/mars.xcframework/ios-arm64/Headers" ' +
    '"${PODS_ROOT}/MarsLog/mars.xcframework/ios-arm64_x86_64-simulator/Headers" ' +
    '"${PODS_ROOT}/MarsLog/mars.xcframework/macos-arm64_x86_64/Headers"'
  }

end
