#
# Be sure to run `pod lib lint GYPageViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GYPageViewController'
  s.version          = '0.1.0'
  s.summary          = 'Implementation a page view controller with scroll view. To solve 2 Problems of UIPageViewController and take the place of UIPageViewController.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/GYPageViewController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GaoYu' => 'fightrain@126.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/GYPageViewController.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'
  s.source_files = 'GYPageViewController/Classes/**/*'
  s.dependency 'HMSegmentedControl', '~> 1.5.2'
end
