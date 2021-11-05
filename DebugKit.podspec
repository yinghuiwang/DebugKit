#
# Be sure to run `pod lib lint DebugKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DebugKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DebugKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/iyinghui@163.com/DebugKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iyinghui@163.com' => 'wangyinghui@changba.com' }
  s.source           = { :git => 'https://github.com/iyinghui@163.com/DebugKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.default_subspec  = "Core"
  
  s.ios.deployment_target = '10.0'

  s.subspec "Core" do |ss|
    ss.source_files = 'DebugKit/Core/**/*.{swift}'
    ss.resource_bundles = {
      'Core' => ['DebugKit/Core/**/*.xib']
    }
  end
  
  s.subspec "Log" do |ss|
    ss.source_files = 'DebugKit/Log/**/*.{swift}'
    ss.resource_bundles = {
      'Log' => ['DebugKit/Log/**/*.xib']
    }
  end
  
  s.subspec "FileLogViewer" do |ss|
    ss.source_files = 'DebugKit/FileLogViewer/**/*.{swift}'
    ss.resource_bundles = {
      'FileLogViewer' => ['DebugKit/FileLogViewer/**/*.xib']
    }
  end
  
  s.subspec "JsonViewer" do |ss|
    ss.source_files = 'DebugKit/JsonViewer/**/*.{swift}'
    ss.resource_bundles = {
      'JsonViewer' => ['DebugKit/JsonViewer/**/*.{html,js,css}']
    }
  end
  
  s.subspec "UserDefaults" do |ss|
    ss.source_files = 'DebugKit/UserDefaults/**/*.{swift}'
    ss.resource_bundles = {
      'UserDefaults' => ['DebugKit/UserDefaults/**/*.{xib}']
    }
  end
  
  s.subspec "MsgSimulation" do |ss|
    ss.source_files = 'DebugKit/MsgSimulation/**/*.{swift}'
    ss.resource_bundles = {
      'MsgSimulation' => ['DebugKit/MsgSimulation/**/*.{xib}']
    }
  end
  

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
