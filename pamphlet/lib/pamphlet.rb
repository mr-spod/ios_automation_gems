require 'singleton'
require 'xcodeproj'
require 'fastlane'
require 'json'
require 'string-eater'
require_relative 'pamphlet/config.rb'
require_relative 'pamphlet/buildMode.rb'
require_relative 'pamphlet/plist.rb'
require_relative 'pamphlet/entitlements.rb'
require_relative 'pamphlet/messenger.rb'

class Pamphlet
  include Singleton

  attr_accessor :projectPath
  attr_accessor :sourcePath
  attr_accessor :apiVersion
  attr_accessor :crashlyticsSecret
  attr_accessor :crashlyticsToken
  attr_accessor :crashlyticsGroups
  attr_accessor :pilotUsername
  attr_accessor :pilotFeedbackEmail
  attr_accessor :jenkinsLogin
  attr_accessor :jenkinsBuildPath
  attr_accessor :messenger
  attr_reader :configHash
  attr_reader :plistHash
  attr_reader :entitlementsHash
  attr_reader :ipaFileNamesHash
  attr_reader :iconsPathHash
  attr_reader :allSchemes

  def initialize
    @configHash = Hash.new
    @plistHash = Hash.new
    @entitlementsHash = Hash.new
    @ipaFileNamesHash = Hash.new
    @iconsPathHash = Hash.new
    @allSchemes = []
  end

  def setNurvDetails(details)
    File.open(Messenger.outputFile, 'w') { |file| file.truncate(0) }
    @messenger = Messenger.new(details)
  end

  def loadConfig
    raise "Project path has not been set" unless @projectPath
    raise "Root directory path has not been set" unless @sourcePath

    configDirs = Dir.glob("#{@sourcePath}/config/*").each { |dir| dir.slice! "#{@sourcePath}/config/" }
    project = Xcodeproj::Project.open("#{@projectPath}")

    Xcodeproj::Project.schemes("#{@projectPath}").each { |scheme|
      @allSchemes << scheme
      configScheme = scheme # trim beta off of scheme for config name
      configScheme.slice!(" - Beta")
      configName = configScheme # separate variables configName and scheme because some config directories are named downcases
      configName = configScheme.downcase if configDirs.include? configScheme.downcase

      if configDirs.include? configName
        @configHash.store(scheme, Config.new("#{@sourcePath}/config/#{configName}/config.json")) # config directories must follow this pattern
        @iconsPathHash.store(scheme, "#{@sourcePath}/config/#{configName}/Assets.xcassets/AppIcon.appiconset")

        target = project.targets.find { |t| t.name == scheme } # targets & schemes must have same name
        releaseConfig = target.build_configurations.find { |config| config.name == "Release" }
        plistPath = adjustedPath(releaseConfig.build_settings["INFOPLIST_FILE"])
        @plistHash.store(scheme, PropertyList.new(plistPath))
        entitlementsPath = adjustedPath(releaseConfig.build_settings["CODE_SIGN_ENTITLEMENTS"])
        @entitlementsHash.store(scheme, Entitlements.new(entitlementsPath))
        @ipaFileNamesHash.store(scheme, Hash.new)
      end
    }
  end

  def adjustedPath(path)
    pathComponents = path.split('/')
    pathComponents.shift if pathComponents[0] == "."
    pathComponents.shift if pathComponents[0] == "$(SRCROOT)"
    pathComponents[0] = @sourcePath
    pathComponents.join('/')
  end

  def generateIpaFileName(scheme, buildNum, mode)
    version = @plistHash[scheme].versionNumber
    timestamp = Time.now.strftime("date%m%d%y_time%H%M")
    ipaName = "#{scheme}_v#{version}_b#{buildNum}_#{timestamp}_#{mode}"
    @ipaFileNamesHash[scheme][mode] = ipaName
    ipaName
  end

  def outputWarning(message)
    @messenger.appendMessage(message, :message)
    Fastlane::UI.important message
  end

  def readSchemeArgs(scheme, args)
    customConfig = args[:config_directory]
    if customConfig != nil && @allSchemes.include?(customConfig)
      @configHash.store(scheme, @configHash[customConfig])
    end
  end

  def tokenizeArgs(scheme, options)
    tokenizer = FastlaneTokenizer.new
    args = options[:args]
    curl_tag_error = "Cannot enter both --curl & --no-curl. Please select only one tag"
    if !args
      options[:skip_curl] = false unless options[:skip_curl]
      options[:staging_suffix] = "staging" unless options[:staging_suffix]
    else
      tokens = tokenizer.tokenize!(args)
      case [tokens.skip_curl.nil?, tokens.no_skip_curl.nil?, tokens.staging_suffix.nil?]
        when [false, true, false]
          options[:skip_curl] = "true"
        when [true, true, false]
          options[:skip_curl] = "false"
        when [false, false, false] || [false, false, true]
          UI.user_error! curl_tag_error
      end

      if tokens.staging_suffix.empty?
        options[:staging_suffix] = "staging"
      else
        options[:staging_suffix] = tokens.staging_suffix
      end
    end
    readSchemeArgs(scheme, options)
    return options
  end

end

class FastlaneTokenizer < StringEater::Tokenizer
  look_for " -u "
  add_field :staging_suffix
  look_for " --curl"
  add_field :skip_curl
  look_for " --no-curl"
  add_field :no_skip_curl
end
