require 'fastlane'
require 'pamphlet'

module GymWrapper
  module_function

  def archive(scheme, mode)
    pam = Pamphlet.instance
    config = pam.configHash[scheme]
    pam.plistHash[scheme].productionBuildNumber #reset build number before each archive
    case mode
    when BuildMode::PRODUCTION
      xcargs = config.xcargsProduction
      exportMethod = "ad-hoc"
      configuration = "Release"
      buildNumber = pam.plistHash[scheme].restoreBuildNumber
    when BuildMode::STORE
      xcargs = config.xcargsProduction
      exportMethod = "app-store"
      configuration = "Store"
      buildNumber = pam.plistHash[scheme].restoreBuildNumber
    when BuildMode::STAGING
      xcargs = config.xcargsStaging
      exportMethod = "ad-hoc"
      configuration = "Release"
      buildNumber = pam.plistHash[scheme].bumpBuildNumber
    when BuildMode::TESTFLIGHT
      xcargs = config.xcargsStaging
      exportMethod = "app-store"
      configuration = "Store"
      buildNumber = pam.plistHash[scheme].bumpBuildNumber
    else
      Fastlane::UI.user_error! "Unexpected build mode sent to archiver: #{mode}"
    end

    ipaFileName = pam.generateIpaFileName(scheme, buildNumber, mode)
    begin
      gym(scheme: scheme,
        configuration: configuration,
        verbose: true,
        clean: true,
        output_name: ipaFileName,
        export_method: exportMethod,
        xcargs: xcargs)
      pam.messenger.appendMessage("Archive succeeded for #{scheme}, #{mode}", :success)
      ipaFileName
    rescue => ex
      pam.messenger.appendMessage("Archive failed for #{scheme}, #{mode} due to an error: #{ex.message}", :error)
      Fastlane::UI.user_error! ex.message
    end
  end
end
