#
# Be sure to run `pod lib lint ProgressStep.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ProgressStep'
  s.version          = '0.2.1'
  s.summary          = 'A view to show progress.'
  s.swift_version    = '5.3'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A view to show progress with half or full step
                       DESC

  s.homepage         = 'https://github.com/Serguitar/ProgressStep'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sergey Lukoyanov' => 'serguitar@mail.ru' }
  s.source           = { :git => 'https://github.com/Serguitar/ProgressStep.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'ProgressStep/Classes/**/*'
end
