Gem::Specification.new do |s|

  s.name	= 'pamphlet'
  s.version	= '0.3.3'
  s.date	= '2018-06-13'
  s.summary	= "Duet Health internal iOS automation info tool"
  s.description	= "Ruby gem that extracts automation information from a Duet iOS project."
  s.authors	= ["Sean O'Donnnell"]
  s.email	= 'info@duethealth.com'
  s.files	= Dir['Rakefile', 'pamphlet/{bin,lib}/**/*', 'README*']
  s.license	= 'MIT'

  s.add_runtime_dependency "xcodeproj"
  s.add_runtime_dependency "plist"
  s.add_runtime_dependency "fastlane"
  s.add_runtime_dependency "string-eater"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "geminabox"

end
