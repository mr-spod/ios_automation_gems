Gem::Specification.new do |s|

  s.name	= 'archiver'
  s.version	= '0.1.1'
  s.date	= '2018-06-18'
  s.summary	= "Duet Health internal iOS automation build stage tool"
  s.description	= "Ruby gem that builds a Duet iOS project."
  s.authors	= ["Sean O'Donnnell"]
  s.email	= 'info@duethealth.com'
  s.files	= Dir['Rakefile', 'archiver/{bin,lib}/**/*', 'README*']
  s.license	= 'MIT'

  s.add_runtime_dependency "fastlane"
  s.add_runtime_dependency "pamphlet"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "geminabox"

end
