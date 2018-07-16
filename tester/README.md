# tester

## *Installation***
### `TBD -- Private gem server, rubygems server, or pull from gitlab`

## Uses

##### TODO: separate unit, UI, integration tests into separate `scan` calls

As of now, this gem is extremely lightweight. The only necessary pamphlet information is the messenger object that will send a log to our NURV channel. Tester contains only one fastlane module which makes a `Fastlane::scan` call to test a given scheme. The Fastfile code to set up the messenger and run tests looks like this:

```
fastlane_require 'pamphlet'
fastlane_require 'tester'

before_all do |lane, options|
  ... pamphlet setup
  Pamphlet.instance.setNurvDetails = {...} # creates messenger object
  ...
end

desc "Runs the tests for a scheme"
lane :test do |args|
  scheme = args[:scheme]
  runTests(scheme)
end
```

Any error/warning messages will be both displayed in the console and appended to the messenger file to be sent to the team via NURV.
