require 'fastlane'
require 'xcodeproj'
require 'pamphlet'

module CrashlyticsWrapper
  module_function

  def uploadToCrashlytics(mode, args)
    pam = Pamphlet.instance
    groups = pam.crashlyticsGroups
    groups << args[:testers] if args[:testers] != nil
    proj = Xcodeproj::Project.open(pam.projectPath)
    name = proj.root_object.name
    begin
      crashlytics(
        api_token: pam.crashlyticsToken,
        build_secret: pam.crashlyticsSecret,
        groups: groups,
        notifications: true,
        notes: "#{name} Client Build - #{mode}"
      )
      message = "Successfully uploaded #{mode} build to Crashlytics"
      pam.messenger.appendMessage(message, :success)
    rescue => ex
      message = "Failed to upload #{mode} build to Crashlytics due to an error:\n#{ex.message}"
      pam.messenger.appendMessage(message, :failure)
      Fastlane::UI.error message
    end
  end

  def executePilot(scheme, mode)
    pam = Pamphlet.instance
    teamId = pam.configHash["scheme"].config["ios"]["team_id"]
    unless teamId.to_s.strip.empty?
      ipaFileName = pam.ipaFileNamesHash[scheme][mode]
      begin
        pilot(username: pam.pilotUsername,
              beta_app_feedback_email: pam.pilotFeedbackEmail,
              ipa: ipaFileName,
              team_id: teamId,
              skip_waiting_for_build_processing: true)

        message = "Successfully uploaded #{scheme} build to TestFlight"
        pam.messenger.appendMessage(message, :success)
      rescue => ex
        message = "Failed to upload #{scheme} store build to TestFlight due to an error:\n#{ex.message}"
        pam.messenger.appendMessage(message, :failure)
        Fastlane::UI.error message
      end
    else
      message = "Could not execute pilot for TestFlight build of #{scheme}, #{mode}:\n'team_id' field in config dictionary not set."
      pam.messenger.appendMessage(message, :failure)
      Fastlane::UI.error message
    end
  end

end
