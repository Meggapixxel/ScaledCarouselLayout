Pod::Spec.new do |s|
  s.name             = 'ScaledCarouselLayout'
  s.version          = '0.1.0'
  s.summary          = 'ScaledCarouselLayout for UICollectionView with easy use'
  s.screenshots      = 'https://raw.githubusercontent.com/Meggapixxel/ScaledCarouselLayout/master/Example1.gif'
  s.description      = <<-DESC
  ScaledCarouselLayout includes storyboard configs:
  - horizontal/vertical scroll direction
  - aspect sizes for scaled & normal UICollectionViewCell  depends on UICollectionView frame
                       DESC
  s.homepage         = 'https://github.com/Meggapixxel/ScaledCarouselLayout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Meggapixxel' => 'zhydenkodeveloper@gmail.com' }
  s.source           = { :git => 'https://github.com/Meggapixxel/ScaledCarouselLayout.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'ScaledCarouselLayout/**/*'
end
