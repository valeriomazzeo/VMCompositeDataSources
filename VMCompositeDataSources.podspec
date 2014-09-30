Pod::Spec.new do |s|
  s.name             = "VMCompositeDataSources"
  s.version          = "0.1.4"
  s.summary          = "Composite data sources for UITableView and UICollectionView."
  s.homepage         = "https://github.com/valeriomazzeo/VMCompositeDataSources"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Valerio Mazzeo" => "valerio.mazzeo@gmail.com" }
  s.source           = { :git => "https://github.com/valeriomazzeo/VMCompositeDataSources.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'VMCompositeDataSources' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'
end
