# pamphlet

lot going on here.

## *Installation***
### `TBD -- Private gem server, rubygems server, or pull from gitlab`

*Important note*** all other duet automation gems (validator, archiver, tester and uploader) require that pamphlet has been configured to some extent.

pamphlet creates a singleton object referenced via `Pamphlet.instance`. This is the singular source for project information used throughout all automation processes.

###### Note*
See the doc for archiver for descriptions of the `BuildMode` enumeration and how it is used.

# Classes
## Pamphlet
##### Read/Write Attributes
The pamphlet object has several attributes that must be assigned values by the client in order to facilitate the automation processes:
- **projectPath** - the relative path from the client's Fastfile to the .xcodeproj file of the client project
- **sourcePath** - the relative path from the client's Fastfile to the directory of the project's source code
- **crashlyticsSecret** - the build secret for crashlytics deployment
- **crashlyticsToken** - the authentication token used for crashlytics deployment
- **crashlyticsGroups** - an array of names of tester groups to which access should be granted on crashlytics
- **pilotUsername** - the email address used to login to TestFlight for uploading builds
- **pilotFeedbackEmail** - the email address given to pilot to which Apple will send feedback about the TestFlight process
- **jenkinsLogin** - the "username:password" formatted login to our private build server
- **jenkinsBuildPath** - the URI for the private build server, with the path to the folder to which builds should be uploaded.
- **messenger** - a `Messenger` object created to generate an output log and to send it as a message to our nurv channel.
  - To create a messenger object, you should pass a Hash into pamphlet's `setNurvDetails` method (see Instance Methods).

##### Read-only Attributes
The pamphlet object will also generate and maintain several readonly attributes containing information read from the file system:
- **allSchemes** - an array containing all of the scheme names in the project
  - filled by `loadConfig` method
- **configHash** - a hash of `Config` objects, keyed by scheme name
  - filled by `loadConfig` method
- **plistHash** - a hash of `Plist` objects, keyed by scheme name
  - filled by `loadConfig` method
- **entitlementsHash** - a hash of `Entitlements` objects, keyed by scheme name
  - filled by `loadConfig` method
- **iconsPathHash** - a hash of paths to the app icon asset catalog, keyed by scheme name
  - filled by `loadConfig` method
  - used for validation
- **ipaFileNamesHash** - a hash containing the filenames of the most recent archived builds, keyed by scheme name and build mode.
  - filled with scheme keys and empty hash values by `loadConfig` method
  - appended to by `generateIpaFileName(buildNum, scheme, mode)` method
  - Use ex.: archiver makes an ipa and puts the file name in this hash, later uploader gets the file name from the hash and uses it to upload to private build server.
  - `storeFileName = Pamphlet.instance.ipaFileNamesHash[scheme][BuildMode::STORE]`
  - Values are overwritten once a new build of the same scheme and build mode has been archived.

##### Instance Methods
- **setNurvDetails(details)**
  - details is a Hash object with NURV api information, should be the following format:
  ```
  {
    "NURV_RECIPIENT_IDS" => ["...", "...", "..."], #id numbers
    "NURV_TOKEN" => "..." #auth token
    "NURV_URL" => "{your-messenger-api}/threads/{thread id}/messages"
  }
  ```
  - creates a `Messenger` object and assigns it to the pamphlet to be accessed anywhere
- **loadConfig**
  - bulk of the work done by the pamphlet
  - for each scheme in the project, do the following:
    - create a `Config` object based on `config.json` and place in **configHash**
    - create a `Plist` object based on `(scheme)-Info.plist` and place in **plistHash**
    - create an `Entitlements` object based on `(scheme).entitlements` and place in **entitlementsHash**
    - store the path to the scheme's app icon asset catalog in **iconsPathHash**
    - initialize the **ipaFileNamesHash** value for the scheme to an empty `Hash` object.
- **adjustedPath(path)**
  - take a path from the project's build settings and modifies it to be relative from the client's Fastfile, based on the **sourcePath** attribute
- **generateIpaFileName(scheme, buildNum, mode)**
  - makes a filename for a soon-to-be-archived .ipa file, and stores that name in **ipaFileNamesHash**
- **tokenizeArgs(scheme, options)**
  - puts argument tokens into a Hash object to be passed around the Fastfile. Also, this method passes the args to **readSchemeArgs(scheme, args)**, in case anything needs to be done to the pamphlet.
- **readSchemeArgs(scheme, args)**
  - looks at the arguments passed in from the command line and makes any necessary changes to the pamphlet
    - ex: build scheme with a custom config directory

## Config
##### Read-only Attributes
- **path** - the relative path in the file system to the `config.json` file this object represents
- **config** - a Ruby `Hash` object containing the content of `config.json`
- **usesEntitlements** - boolean indicating whether the config uses the classic `staging`/`production` pattern [false], or uses an array of `environments` to define its backend URLs [true].
- **environments** - the contents of `config["environments"]`, if that value exists in the `config.json`

##### Instance Methods
- **xcargsStaging** - build phase arguments used for a "staging" build (BuildMode::STAGING, BuildMode::TESTFLIGHT).
  - preprocessor argument `PRODUCTION_BUILD=0`
- **xcargsProduction** - build phase arguments used for a "production" build (BuildMode::PRODUCTION, BuildMode::STORE).
  - preprocessor argument `PRODUCTION_BUILD=1`

## Plist
##### Read-only Attributes
- **path** - the relative path in the file system to the `Info.plist` file this object represents
  - taken from the scheme's build settings

##### Read/Write Attributes
- **plist** - a Ruby `Hash` object containing the content of `Info.plist`
  - this is read/write because sometimes the automation process changes the plist

##### Instance Methods ------ ***TODO, build number maintenence****
- **writePlist** - writes the contents of the instance's **plist** Hash to the `Info.plist` file in the file system.
- **versionNumber** - returns the application version number stored in the plist
- **productionBuildNumber** - the build number that should be used for "production" builds.
  - This is the build number that was in the plist when `loadConfig` was called on the pamphlet initially
  - Writes the returned build number to the plist
- **{staging/bump}BuildNumber** - the build number that should be used for "staging" builds.
  - This build number is calculated based on the production build number.
  - Writes the returned build number to the plist

## Entitlements
##### Read-only Attributes
- **path** - the relative path in the file system to the `.entitlements` file this object represents
  - taken from the scheme's build settings

##### Read/Write Attributes
- **entitlements** - a Ruby `Hash` object containing the content of `.entitlements`
  - this is read/write because sometimes the automation process changes the entitlements

##### Instance Methods
- **writeEntitlements** - writes the contents of the instance's **entitlements** Hash to the `.entitlements` file in the file system.

## Messenger
##### Static Attributes
- **outputFile** - path for output to be written to.
  - hardcoded as `./build.out`

##### Instance Methods
- **appendMessage** - appends a line to the output file with the given message and message type
  - message types:
    - `:success` 🎉
    - `:error`   🚫
    - `:failure` ⚠️
    - `:message` 💬
- **sendOuput** - uses cURL to send the contents of the output file in a message to our NURV channel
