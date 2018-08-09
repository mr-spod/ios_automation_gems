Gem::Specification.new do |s|

  s.name	= 'validator'
  s.version	= '1.1.2'
  s.date	= '2018-06-15'
  s.summary	= "Duet Health internal iOS automation validation tool"
  s.description	= "Ruby gem that validates the contents of an iOS application project for deployment."
  s.authors	= ["Sean O'Donnnell"]
  s.email	= 'info@duethealth.com'
  s.files	= Dir['Rakefile', 'validator/{bin,lib}/**/*', 'README*']
  s.license	= 'MIT'

  s.add_runtime_dependency "pamphlet"
  s.add_runtime_dependency "fastimage"
  s.add_runtime_dependency "fastlane"
  s.add_runtime_dependency "xcodeproj"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "geminabox"
end
