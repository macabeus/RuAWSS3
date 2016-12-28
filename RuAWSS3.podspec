#
# Be sure to run `pod lib lint RuAWSS3.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RuAWSS3'
  s.version          = '0.1.0'
  s.summary          = 'Ridiculously Uncomplicated AWS S3'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod abstracts the (unnecessarily) complicated Amazon's official library for S3.
Also, asynchronous calls are encapsulated with PromiseKit.
                       DESC

  s.homepage         = 'https://github.com/brunomacabeusbr/RuAWSS3'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Macabeus' => 'bruno.macabeus@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/RuAWSS3.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RuAWSS3/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RuAWSS3' => ['RuAWSS3/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AWSS3', '~> 2.4.16'
  s.dependency 'PromiseKit', '~> 4.0'

end
