require 'pamphlet'
require 'xcodeproj'
require 'fastimage'
require 'fastlane'
require_relative 'validator/fastlaneHelper.rb'
require_relative 'validator/validAPI.rb'
require_relative 'validator/validPlist.rb'
require_relative 'validator/validPamphlet.rb'

class Validator
  def self.validate(scheme, args)
    Fastlane::UI.message "Validating..."
    pam = Pamphlet.instance

    begin
      ValidPamphlet.validate(pam)
    rescue => ex
      Fastlane::UI.user_error! "Pamphlet error:\n#{ex.message}"
    end

    messenger = pam.messenger
    plist = pam.plistHash[scheme].plist
    messenger.appendMessage("#{scheme}, Version: #{plist["CFBundleShortVersionString"]}, Build: #{plist["CFBundleVersion"]}", :message)

    schemes = Xcodeproj::Project.schemes("#{pam.projectPath}")
    schemeExists = schemes.include? scheme
    unless schemeExists
      message = "Scheme #{scheme} not found in the xcode project named #{pam.projectPath}. May be case sensitive."
      messenger.appendMessage(message, :error)
      Fastlane::UI.user_error! message
    end

    iconsPath = pam.iconsPathHash[scheme]
    appStoreIcon = Dir.glob("#{iconsPath}/*").any? { |imagePath|
      FastImage.size(imagePath) == [1024, 1024]
    }
    unless appStoreIcon
      message = "No 1024x1024 size app icon for #{scheme} at #{iconsPath}."
      messenger.appendMessage(message, :error)
      Fastlane::UI.user_error! message
    end

    unless args[:skip_api_validation]
      Fastlane::UI.command "API Validation"
      stagingSuffix = args[:staging_suffix]
      apiValidator = APIValidator.new(scheme, args["api_version"], stagingSuffix)
      apiValidator.validateAPIRegex
      apiValidator.validateAPIPing()
      Fastlane::UI.message "Finished api validation"
    end

    plistValidator = PlistValidator.new(scheme)
    plistValidator.validatePlist
    Fastlane::UI.message "Finished plist validation"

  end
end
