# archiver

## *Installation***
### `TBD -- Private gem server, rubygems server, or pull from gitlab`

## Uses
_Important Note*_ Archiver requires that you have already set up a Pamphlet singleton.
These examples assume this has been done, **_and that the pamphlet has been validated by the `validator` gem_**.

### Creating a build

To generate a build, Archiver makes a `Fastlane::gym` call inside a Fastlane helper module.

There are 4 possible sets of parameters for an archive in our deployment process. They are represented in an enum as `BuildMode`s.

###### BuildModes
1. STAGING
  - export method "ad-hoc"
  - configuration "Release"
  - staging build number
  - staging xcargs `"PRODUCTION_BUILD"=0`
2. PRODUCTION
  - export method "ad-hoc"
  - configuration "Release"
  - production build number
  - production xcargs `"PRODUCTION_BUILD"=1`
3. STORE
  - export method "app-store"
  - configuration "Store"
  - production build number
  - production xcargs `"PRODUCTION_BUILD"=1`
4. TESTFLIGHT
  - export method "app-store"
  - configuration "Store"
  - staging build number
  - staging xcargs `"PRODUCTION_BUILD"=0`

Given a scheme to archive and a build mode to use, Archiver will generate an .ipa file for you. The method to do so also returns the name of the newly generated file, to be used elsewhere as needed.
The Fastfile code to archive a build is as follows:
```
fastlane_require 'pamphlet'
fastlane_require 'archiver'

lane :appStoreArchive do |args|
  scheme = args[:scheme]
  fileName = archive(scheme, BuildMode::STORE)
  puts "Successful archive, file named: #{fileName}"
end
```

Any error/warning messages will be both displayed in the console and appended to the messenger file to be sent to the team via NURV.
