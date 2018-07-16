require 'fastlane'
require 'pamphlet'

module ScanWrapper
  module_function

  def runTests(scheme)
    messenger = Pamphlet.instance.messenger
    begin
      scan(scheme: scheme, devices: ["iPhone 7"])
      messenger.appendMessage("All tests passed for #{scheme}", :success)
    rescue => ex
      messenger.appendMessage("Some tests failed for #{scheme} due to an error: \n#{ex.message}", :failure)
      Fastlane::UI.error ex.message
    end
  end
end
