# uploader

## *Installation***
### `TBD -- Private gem server, rubygems server, or pull from gitlab`

## Uses
_Important Note*_ Uploader requires that you have already set up a Pamphlet singleton.
These examples assume this has been done, **_and that the pamphlet has been validated by the `validator` gem_**.

### Crashlytics
Uploader is capable of uploading the most recently archived .ipa file to Crashlytics.
###### Required Pamphlet information for crashlytics:
1. Build secret
  - explicitly assigned
2. Api token
  - explicitly assigned
3. Tester groups
  - explicitly assigned
  - Format: ["testGroupA"] or ["testGroupB", "testGroupC"]

Since Fastlane is capable of detecting the most recent .ipa to have been archived, all we have to do to upload the build is the following:
```
fastlane_require 'uploader'
fastlane_require 'pamphlet'

extend CrashlyticsWrapper # get access to `crashlytics` helper function

before_all do |lane, options|
  ... pamphlet setup
  Pamphlet.instance.crashlyticsToken = "..."
  Pamphlet.instance.crashlyticsSecret = "..."
  Pamphlet.instance.crashlyticsGroups = ["testGroupA"]
  ...
end

lane :fabricProductionUpload do |args|
  uploadToCrashlytics(BuildMode::PRODUCTION)
end
```
It will detect the last build to have been generated and upload it to Crashlytics based on the information stored in Pamphlet.

Any error/warning messages will be both displayed in the console and appended to the messenger file to be sent to the team via NURV.

### TestFlight
Sometimes we want to upload a build to TestFlight. I've certainly never done it, so anyone who has/does regularly may want to update this section of the documentation with more information, and maybe suggest changes to how TestFlight is handled here. Uploader uses the `Fastlane::pilot` command.

###### Required Pamphlet information for testflight:
1. Developer team id
  - read from config file
2. Beta feedback email
  - explicitly assigned
3. Username
  - explicitly assigned

The Fastfile code to upload to TestFlight would look like this:

```
fastlane_require 'uploader'
fastlane_require 'pamphlet'

extend CrashlyticsWrapper # get access to `pilot` helper function

before_all do |lane, options|
  ... pamphlet setup
  Pamphlet.instance.pilotUsername = "super.dev@duethealth.com"
  Pamphlet.instance.pilotFeedbackEmail = "info@duethealth.com"
  ...
end

lane :testFlight do |args|
  scheme = args[:scheme]
  executePilot(scheme, BuildMode::TESTFLIGHT)
end
```

Any error/warning messages will be both displayed in the console and appended to the messenger file to be sent to the team via NURV.


### cURL

Our development team stores .ipa files on a build server. Information about this build server is used by Uploader to deliver .ipa files to the server.

###### Required Pamphlet information for curl:
1. Jenkins Username
  - Explicitly assigned
2. Jenkins build path
  - Explicitly assigned
  - path to builds directory on jenkins

The Fastfile code to upload an archived .ipa to the build server is as follows:

```
fastlane_require 'uploader'
fastlane_require 'pamphlet'

before_all do |lane, options|
  ... pamphlet setup
  Pamphlet.instance.jenkinsLogin = "username:password"
  Pamphlet.instance.jenkinsBuildPath = "smb://xyz.a.bc.cd/builds/ios/patient"
  ...
end

lane :jenkinsUpload do |args|
  scheme = args[:scheme]
  Uploader.uploadToBuildServer(scheme, BuildMode::STAGING)
end
```

Any error/warning messages will be both displayed in the console and appended to the messenger file to be sent to the team via NURV.
