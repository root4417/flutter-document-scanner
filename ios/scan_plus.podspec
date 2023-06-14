#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint scan_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'scan_plus'
  s.version          = '0.0.1'
  s.summary          = 'Scan Plus'
  s.description      = 'Scan Plus is a flutter document scanner plugin'
  s.homepage         = 'https://hexasoft.io'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'HEXASOFT' => 'arshad@hexasoft.io' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'
  s.dependency 'WeScan', '>= 0.9'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
end
