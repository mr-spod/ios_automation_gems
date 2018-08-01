require 'pamphlet'
require 'fastlane'

class APIValidator

  def initialize(scheme, apiVersion, stagingSuffix = nil)
    @scheme = scheme
    @stagingSuffix = stagingSuffix
    @configObject = Pamphlet.instance.configHash[scheme]
    @messenger = Pamphlet.instance.messenger
    @sharedPatterns = [[/^https/, "URL is not https"]]
    readConfigURLs(apiVersion)
  end

  def readConfigURLs(apiVersion)
    config = @configObject.config
    if @configObject.usesEnvironments
      stagingURL = config["environments"][1]["url"]
      productionURL = config["environments"][0]["url"]
      @stagingAPI = "#{stagingURL}/#{apiVersion}"
      @productionAPI = "#{productionURL}/#{apiVersion}"
    else
      @stagingAPI = config["staging_url"]
      @productionAPI = config["production_url"]
      extensionRegex = Regexp.new "#{apiVersion.chomp('/')}$"
      @sharedPatterns << [extensionRegex, "API level does not match API version in Fastfile -- #{apiVersion}"]
    end
  end

  def validateAPIRegex
    stagingValidRegex(@stagingAPI)
    productionValidRegex(@productionAPI)
  end

  def validateAPIPing
    # TODO: for environments that may not return a 200 on a ping to their site w/o auth, we should think of a workaround
    pingAPI(@stagingAPI, "staging")
    pingAPI(@productionAPI, "production")
  end

  def stagingValidRegex(stagingAPI)
    if @stagingSuffix != nil
      Fastlane::UI.message "Validating with custom staging pattern '#{@stagingSuffix}'"
      stagingPattern = Regexp.new "/[a-z]+-#{@stagingSuffix}.duethealth.com"
    else
      Fastlane::UI.message "Validating with default staging pattern"
      stagingPattern = /[a-z]+-staging.duethealth.com/
    end
    (@sharedPatterns + [[stagingPattern, "URL does not point to staging environment"]]).each { |tuple|
      unless tuple[0].match stagingAPI
        message = "#{@scheme}\'s staging URL did not pass validation.\nReason: #{tuple[1]}"
        @messenger.appendMessage(message, :error)
        Fastlane::UI.user_error! message
      end
    }
  end

  def productionValidRegex(productionAPI)
    (@sharedPatterns + [[/\/[a-z]+.duethealth.com/, "URL does not point to production environment"]]).each { |tuple|
      unless tuple[0].match productionAPI
        message = "#{@scheme}\'s production URL did not pass validation.\nReason: #{tuple[1]}"
        @messenger.appendMessage(message, :error)
        Fastlane::UI.user_error! message
      end
    }
  end

  def pingAPI(url, environment)
    uri = URI.parse(url)
    begin
      response = Net::HTTP.get_response(uri)
      if response.code == "404"
        message = "Config/backend not up to date for #{@scheme} #{environment}. Received a 404 from url #{url}."
        @messenger.appendMessage(message, :failure)
        Fastlane::UI.error message
      else
        Fastlane::UI.success "Successful API ping from #{url}, status code #{response.code}."
      end
    rescue => ex
      message = "Failed to validate backend for #{@scheme} #{environment}. An error occured when pinging url #{url}: #{ex.message}."
      @messenger.appendMessage(message, :failure)
      Fastlane::UI.error message
    end
  end

end
