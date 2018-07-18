require 'plist'

class Entitlements

  attr_reader :path
  attr_accessor :entitlements

  def initialize(entitlementsPath)
    @path = entitlementsPath
    @entitlements = Plist.parse_xml entitlementsPath
  end

  def printEntitlements
    puts JSON.pretty_generate @entitlements
  end

  def writeEntitlements
    File.open(@path, 'w') { |file| file.truncate(0) }
    File.open(@path, 'a') { |file|
      file.puts Plist::Emit.dump(@entitlements)
    }
  end

end
