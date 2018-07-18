require 'pamphlet'

class ValidPamphlet

  def self.validate(pamphlet)
    raise "Pamphlet crashlytics token has not been set" unless pamphlet.crashlyticsToken
    raise "Pamphlet crashlytics secret has not been set" unless pamphlet.crashlyticsSecret
    raise "Pamphlet deployment groups array has not been set" unless pamphlet.crashlyticsGroups
    raise "Pamphlet pilot username has not been set" unless pamphlet.pilotUsername
    raise "Pamphlet pilot feedback email has not been set" unless pamphlet.pilotFeedbackEmail
    raise "Pamphlet build server username:password has not been set" unless pamphlet.jenkinsLogin
    raise "Pamphlet build server path has not been set" unless pamphlet.jenkinsBuildPath
    raise "Pamphlet NURV messenger has not been setup. Pass in the necessary info." unless pamphlet.messenger
  end

end
