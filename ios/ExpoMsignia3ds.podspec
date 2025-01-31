require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'ExpoMsignia3ds'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.swift_version  = '5.4'
  s.source         = { git: 'https://github.com/David-Montenegro/test-module.git' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'

  s.source = { :git => 'https://github.com/David-Montenegro/test-module.git'}
  # Swift/Objective-C compatibility
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  # s.source_files = "**/*.{h,m,mm,swift,hpp,cpp}"
  s.source_files = "**/*.{h,m,swift}"
  s.exclude_files="uSDK.xcframework/**/*.h"
  s.vendored_frameworks = 'uSDK.xcframework'
end
