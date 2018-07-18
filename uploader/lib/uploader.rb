require 'pamphlet'
require_relative 'uploader/fastlaneHelper.rb'

class Uploader
  def self.uploadToBuildServer(scheme, mode)
    @@pam = Pamphlet.instance unless @@pam != nil
    ipaPath = "#{@@pam.jenkinsBuildPath}/#{scheme.downcase}/"
    ipaFileName = @@pam.ipaFileNamesHash[scheme][mode]
    login = @@pam.jenkinsLogin
    begin
      # Notice the relative file path
      status = system("curl -u #{login} -T ../#{ipaFileName}.ipa #{ipaPath} --max-time 180")
      unless status
        message = "Failed to upload #{scheme}, #{mode} ipa to build server."
        @@pam.messenger.appendMessage(message, :failure)
        Fastlane::UI.error message
      end
    rescue => ex
      message = "Failed to upload #{scheme}, #{mode} ipa to build server due to an error: \n#{ex.message}"
      @@pam.messenger.appendMessage(message, :failure)
      Fastlane::UI.error message
    end
  end
end
