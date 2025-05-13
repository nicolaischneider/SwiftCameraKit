Pod::Spec.new do |s|
  s.name             = 'SwiftCameraKit'
  s.version          = '1.0.0'
  s.summary          = 'A lightweight iOS camera library for photo and video capture with an easy-to-use API.'
  s.description      = <<-DESC
  An iOS camera library for photo and video capture with an easy-to-use API, flash control, camera switching, and configurable settings.
                       DESC

  s.homepage         = 'https://github.com/nicolaischneider/SwiftCameraKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Nicolai Schneider' => 'nicolaischneiderdev@gmail.com' }
  s.source           = { :git => 'https://github.com/nicolaischneider/SwiftCameraKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.5'

  s.source_files = 'Sources/SwiftCameraKit/**/*'
end