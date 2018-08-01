Gem::Specification.new do |s|

  s.name	= 'tester'
  s.version	= '1.0.0'
  s.date	= '2018-06-18'
  s.summary	= "Duet Health internal iOS automation test stage tool"
  s.description	= "Ruby gem that runs the tests on a Duet iOS project."
  s.authors	= ["Sean O'Donnnell"]
  s.email	= 'info@duethealth.com'
  s.files	= Dir['Rakefile', 'tester/{bin,lib}/**/*', 'README*']
  s.license	= 'MIT'

  s.add_runtime_dependency "fastlane"
  s.add_runtime_dependency "pamphlet"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "geminabox"

end
