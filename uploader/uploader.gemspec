Gem::Specification.new do |s|

  s.name	= 'uploader'
  s.version	= '1.0.0'
  s.date	= '2018-06-29'
  s.summary	= "Duet Health internal iOS automation deployment stage tool"
  s.description	= "Ruby gem that uploads a Duet iOS project to our build servers."
  s.authors	= ["Sean O'Donnnell"]
  s.email	= 'info@duethealth.com'
  s.files	= Dir['Rakefile', 'uploader/{bin,lib}/**/*', 'README*']
  s.license	= 'MIT'

  s.add_runtime_dependency "fastlane"
  s.add_runtime_dependency "pamphlet"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "geminabox"

end
