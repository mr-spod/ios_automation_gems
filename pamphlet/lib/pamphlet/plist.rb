require 'plist'
require 'fastlane'
require_relative 'buildMode.rb'

BUILD_NUM_KEY = 'CFBundleVersion'
VERSION_KEY = 'CFBundleShortVersionString'

class PropertyList
  attr_reader :path
  attr_accessor :plist

  def initialize(plistPath)
    @path = plistPath
    @plist = Plist.parse_xml plistPath
    @initialBuildNumber = @plist[BUILD_NUM_KEY]
  end

  def printPlist
    puts JSON.pretty_generate @plist
  end

  def writePlist
    File.open(@path, 'w') { |file| file.truncate(0) }
    File.open(@path, 'a') { |file|
      file.puts Plist::Emit.dump(@plist)
    }
  end

  def versionNumber
    @plist[VERSION_KEY]
  end


  def productionBuildNumber

  end

  ## This method overwrites the plist with the initial build number, returned to be used in ipa filename
  def restoreBuildNumber
    @plist[BUILD_NUM_KEY] = @initialBuildNumber
    writePlist
  end

  ## This method overwrites the plist with the staging build number, returned to be used in ipa filename
  def bumpBuildNumber(full = false)
    current = @plist[BUILD_NUM_KEY]
    newNum = current
    major, minor = current.split('.').map { |component| component.to_i }
    if full
      newNum = "#{major + 1}.0"
    elsif minor
      case minor
      when 0
        newNum = "#{major}.1"
      when 1
        newNum = "#{major + 1}.0"
      else
        Fastlane::UI.error "Unexpected build number #{current}. Please manually adjust the number and retry."
      end
    else
      Fastlane::UI.error "Unexpected build number #{current}. Please manually adjust the number and retry."
    end
    @plist[BUILD_NUM_KEY] = newNum
    writePlist
  end
end
