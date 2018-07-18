require 'pamphlet'
require 'fastlane'
require 'json'

PLIST_VALUES = {
  "NSCameraUsageDescription" => "Access camera for user image/video content.",
  "NSLocationWhenInUseUsageDescription" => "Access location while using the application.",
  "NSMicrophoneUsageDescription" => "Access microphone for video streaming/recording.",
  "NSPhotoLibraryUsageDescription" => "Access photo library for user uploaded image/video content.",
  "NSAppleMusicUsageDescription" => "Access media library for media viewing/playback.",
  "NSCalendarsUsageDescription" => "Access calendars for important dates and events.",
  "NSPhotoLibraryAddUsageDescription" => "Add to photo library for local storage of application image/video content.",
  "NSHealthShareUsageDescription" => "Automatically add HealthKit information to your profile.",
  "NSHealthUpdateUsageDescription" => "Update HealthKit data from this application."
}

HEALTHKIT_ENTITLEMENTS_KEY = "com.apple.developer.healthkit"

class PlistValidator

  def initialize(scheme)
    @scheme = scheme
    pam = Pamphlet.instance
    @messenger = pam.messenger
    @config = pam.configHash[scheme].config
    @plistObj = pam.plistHash[scheme]
    @entitlementsObj = pam.entitlementsHash[scheme]
  end

  def validatePlist
    plist = @plistObj.plist
    entitlements = @entitlementsObj.entitlements
    healthkit = @config["ios"]["enable_healthkit"]

    if healthkit
      entitlements.store(HEALTHKIT_ENTITLEMENTS_KEY, true) unless entitlements.has_key?(HEALTHKIT_ENTITLEMENTS_KEY)
    else
      entitlements.delete(HEALTHKIT_ENTITLEMENTS_KEY) if entitlements.has_key?(HEALTHKIT_ENTITLEMENTS_KEY)
    end
    @entitlementsObj.entitlements = entitlements
    @entitlementsObj.writeEntitlements

    PLIST_VALUES.keys.each { |key|
      if key.include? "Health"
        if healthkit
          pStore(plist, key)
        else
          pDelete(plist, key)
        end
      else
        pStore(plist, key)
      end
    }
    @plistObj.plist = plist
    @plistObj.writePlist
  end

  def pStore(plist, key)
    unless plist.has_key?(key)
      plist.store(key, PLIST_VALUES[key])
      message = "Added default key/value pair for plist key #{key}."
      @messenger.appendMessage(message, :message)
      Fastlane::UI.important message
    end
  end

  def pDelete(plist, key)
    if plist.has_key?(key)
      plist.delete(key)
      message = "Removed key/value pair for plist key #{key}."
      @messenger.appendMessage(message, :message)
      Fastlane::UI.important message
    end
  end

end
