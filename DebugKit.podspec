#
# Be sure to run `pod lib lint DebugKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DebugKit'
  s.version          = '0.4.1'
  s.summary          = '方便调试的工具箱'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  方便调试的工具箱
                       DESC

  s.homepage         = 'http://gitlab.changbaops.com/wangyinghui/DebugKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iyinghui@163.com' => 'wangyinghui@changba.com' }
  s.source           = { :git => 'git@gitlab.changbaops.com:wangyinghui/DebugKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.default_subspec  = "Core"
  
  s.ios.deployment_target = '10.0'

  s.subspec "Core" do |ss|
    ss.source_files = 'DebugKit/Core/**/*.{swift}'
    ss.resource_bundles = {
      'Core' => ['DebugKit/Core/**/*.xib', 'DebugKit/Core/Resources/*']
    }
  end
  
  s.subspec "H5Portal" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.source_files = 'DebugKit/H5Portal/**/*.{swift}'
    ss.resource_bundles = {
      'H5Portal' => ['DebugKit/H5Portal/**/*.xib']
    }
  end
  
  s.subspec "Log" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.source_files = 'DebugKit/Log/**/*.{swift}'
    ss.resource_bundles = {
      'Log' => ['DebugKit/Log/**/*.xib']
    }
  end
  
  s.subspec "FileLogViewer" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.dependency 'DebugKit/Log'
    ss.dependency 'DebugKit/JsonViewer'
    ss.source_files = 'DebugKit/FileLogViewer/**/*.{swift}'
    ss.resource_bundles = {
      'FileLogViewer' => ['DebugKit/FileLogViewer/**/*.xib']
    }
  end
  
  s.subspec "JsonViewer" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.source_files = 'DebugKit/JsonViewer/**/*.{swift}'
    ss.resource_bundles = {
      'JsonViewer' => ['DebugKit/JsonViewer/**/*.{html,js,css}']
    }
  end
  
  s.subspec "UserDefaults" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.source_files = 'DebugKit/UserDefaults/**/*.{swift}'
    ss.resource_bundles = {
      'UserDefaults' => ['DebugKit/UserDefaults/**/*.{xib}']
    }
  end
  
  s.subspec "MsgSimulation" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.dependency 'DebugKit/Log'
    ss.source_files = 'DebugKit/MsgSimulation/**/*.{swift}'
    ss.resource_bundles = {
      'MsgSimulation' => ['DebugKit/MsgSimulation/**/*.{xib}']
    }
  end
  
  s.subspec "InfoViewer" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.source_files = 'DebugKit/InfoViewer/**/*.{swift}'
    ss.resource_bundles = {
      'InfoViewer' => ['DebugKit/InfoViewer/**/*.{xib}']
    }
  end
  
  s.subspec "HTTPSimulation" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.dependency 'DebugKit/JsonViewer'
    ss.source_files = 'DebugKit/HTTPSimulation/**/*.{swift}'
    ss.resource_bundles = {
      'HTTPSimulation' => ['DebugKit/HTTPSimulation/**/*.{xib}']
    }
  end
  
  s.subspec "AppConfig" do |ss|
    ss.dependency 'DebugKit/Core'
    ss.source_files = 'DebugKit/AppConfig/**/*.{swift}'
    ss.resource_bundles = {
      'AppConfig' => ['DebugKit/AppConfig/**/*.{xib}']
    }
  end
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
