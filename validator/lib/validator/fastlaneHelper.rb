require 'fastlane'
require 'pamphlet'

module MatchWrapper
  module_function

  def syncCerts
    schemes = Pamphlet.instance.allSchemes
    schemes.each { |s| executeMatch(s) }
  end

  def getCerts(scheme)
    config = Pamphlet.instance.configHash[scheme].config
    gitURL = 'git@gitlab.duethealth.com:ios-projects/Code-Signing.git'
    bundleId = config['bundle_id']
    fastlaneConfig = config['ios']['fastlane']
    gitBranch = fastlaneConfig['match_git_branch']
    username = fastlaneConfig['username']
    teamName = fastlaneConfig['team_name']
    teamId = fastlaneConfig['team_id']
    begin
      ['development', 'adhoc', 'appstore'].each { |type|
        match(
          app_identifier: bundleId,
          git_url: gitURL,
          git_branch: gitBranch,
          username: username,
          team_name: teamName,
          team_id: teamId,
          type: type,
          clone_branch_directly: true,
          force_for_new_devices: true,
          shallow_clone: true
        )
      }
    rescue => ex
      Fastlane::UI.error ex.message
    end
  end
end
