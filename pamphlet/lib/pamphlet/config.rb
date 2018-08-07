require 'json'

class Config

  attr_reader :path
  attr_reader :config
  attr_reader :usesEnvironments
  attr_reader :environments

  def initialize(configPath)
    @path = configPath
    @config = JSON.parse File.read configPath
    @usesEnvironments = @config.has_key?("environments")
    @environments = @config["environments"] if @usesEnvironments
  end

  def printConfig
    puts JSON.pretty_generate @config
  end

  def xcargsProduction
    args = "GCC_PREPROCESSOR_DEFINITIONS='PRODUCTION_BUILD=1"
    if @config["ios"]["enable_healthkit"] == true
      args = "#{args}, HEALTHKIT_IN_USE=1, RELEASE=1, COCOAPODS=1'"
    else
      args = "#{args}'"
    end
    args
  end

  def xcargsStaging
    args = "GCC_PREPROCESSOR_DEFINITIONS='PRODUCTION_BUILD=0"
    if @config["ios"]["enable_healthkit"] == true
      args = "#{args}, HEALTHKIT_IN_USE=1, RELEASE=1, COCOAPODS=1'"
    else
      args = "#{args}'"
    end
    args
  end

end
