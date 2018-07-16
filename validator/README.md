# validator

## *Installation***

### `TBD -- Either private gem repo, rubygems official repo or via gitlab`

## Uses
Validator requires that you have already set up a Pamphlet singleton.
This doc is assuming this has already been done.

### 5-Step Validation:
The ***Fastfile*** code to run the validations would look like this:
```
fastlane_require 'pamphlet'
fastlane_require 'validator'

desc "Validates a scheme"
lane :validate do |args|
  scheme = args[:scheme]
  params = Pamphlet.instance.tokenizeArgs(scheme, args[:forwarded])

  Validator.validate(scheme, params) unless params[:skip_validation]

  Pamphlet.instance.messenger.sendOutput
end
```

When `Validator.validate()` is called, any failure to validate will result in a stop in execution and an error message. For this reason, it is recommended to run validation before doing any time-consuming tasks. Any error/warning messages will be both displayed in the console and appended to the messenger file to be sent to the team via NURV.

#### 1: Pamphlet Validation
Validator makes sure that you have put all of the necessary information into your pamphlet.
Certain pieces of private info must be passed into the Pamphlet to be used during the automated build processes.

###### Values that must be nonnull on `Pamphlet.instance`
* crashlyticsToken
* crashlyticsSecret
* crashlyticsGroups
* pilotUsername
* pilotFeedbackEmail
* jenkinsLogin
* jenkinsBuildPath
* messenger
  - messenger will only exist if the NURV details of the Pamphlet have been set
  - NURV details include thread id, recipient id's and auth token.


#### 2: Scheme Validation
Checks that the scheme you have asked to validate is an actual scheme of the Xcode project.

#### 3: Asset Validation
As of now, this is just a check that there exists a 1024x1024 px image in the scheme's config asset catalog for the app store.

#### 4: API Validation
This step does 2 things:
 1. Ping each backend URL in the scheme's config file. This would be staging + production, or each of the URLs in the config's `environments` array.
  - If a 404 is received, a warning is given.
 2. Regex validation of backend URLs in the scheme's config file. This ensures that the config's URLs match the expected patterns.
  - Note: this can be skipped with argument `skip_api_validation:true`

#### 5: Plist/Entitlements Validation
This step looks through the scheme's plist and adds/removes key/value pairs as necessary. This step also adds HealthKit k/v pair to the entitlements file if it isn't there & should be.
###### plist values added by default if not found:
 * Privacy - Camera Usage Description
    - K: NSCameraUsageDescription
    - V: "Access camera for user image/video content."
 * Privacy - Location When In Use Usage Description
    - K: NSLocationWhenInUseUsageDescription
    - V: "Access location while using the application."
 * Privacy - Microphone Usage Description
    - K: NSMicrophoneUsageDescription
    - V: "Access microphone for video streaming/recording."
 * Privacy - Photo Library Usage Description
    - K: NSPhotoLibraryUsageDescription
    - V: "Access photo library for user uploaded image/video content."
 * Privacy - Media Library Usage Description
    - K: NSAppleMusicUsageDescription
    - V: "Access media library for media viewing/playback."
 * Privacy - Calendars Usage Description
    - K: NSCalendarsUsageDescription
    - V: "Access calendars for important dates and events."
 * Privacy - Photo Library Additions Usage Description
    - K: NSPhotoLibraryAddUsageDescription
    - V: "Add to photo library for local storage of application image/video content."
 * Privacy - Health Share Usage Description
    - (if config[ios][enable_healthkit] is true)
    - K: NSHealthShareUsageDescription
    - V: "Automatically add HealthKit information to your profile."
 * Privacy - Health Update Usage Description
    - (if config[ios][enable_healthkit] is true)
    - K: NSHealthUpdateUsageDescription
    - V: "Update HealthKit data from this application."

###### plist values removed by default if found:
* Privacy - Health Share Usage Description
   - (if config[ios][enable_healthkit] is false or not present)
   - K: NSHealthShareUsageDescription
* Privacy - Health Update Usage Description
   - (if config[ios][enable_healthkit] is false or not present)
   - K: NSHealthUpdateUsageDescription

### Code Signing Certificate Matching
Validator has a fastlane helper that calls `Fastlane::match` for you. To access this method from a ***Fastfile***, you must extend the module the `match` call lives in. The information needed for match is pulled from the config file of a given scheme. It will call match for project configurations `Debug`, `Release` and `Store`.

```
fastlane_require 'pamphlet'
fastlane_require 'validator'

extend MatchWrapper # get access to `match` helper function

desc "Runs match for all configurations of the given scheme"
lane :getSchemeCerts do |args|
 scheme = args[:scheme]
 getCerts(scheme)
end

desc "Runs match for all schemes and all configurations"
lane :getAllCerts do |args|
 syncCerts()
end
```
