class Messenger

  @@outputFile = "./build.out"

  def self.outputFile
    @@outputFile
  end

  def initialize(nurvDetails)
    raise "NURV details must include value for key \"NURV_RECIPIENT_IDS\"" unless nurvDetails["NURV_RECIPIENT_IDS"]
    raise "NURV details must include value for key \"NURV_TOKEN\"" unless nurvDetails["NURV_TOKEN"]
    raise "NURV details must include value for key \"NURV_URL\"" unless nurvDetails["NURV_URL"]
    @details = nurvDetails
  end

  def sendOutput
    message = File.read @@outputFile
    json = %Q['{"users": #{@details["NURV_RECIPIENT_IDS"]}, "message": {"message": "#{message}", "notification_type": "normal", "reminder_seconds": 0, "location": "", "lat": null, "long": null, "media": []}}']
    system "curl -H 'Authorization: #{@details["NURV_TOKEN"]}' -H 'Content-Type: application/json' -d #{json} #{@details["NURV_URL"]}}"
  end

  def appendMessage(message, type)
    case type
    when :success
      special = "🎉"
    when :error
      special = "🚫"
    when :failure
      special = "⚠️"
    when :message
      special = "💬"
    when :none
      special = ""
    else UI.user_error! "Unrecognized type sent to appendMessage"
    end
    open(@@outputFile, 'a') { |f|
      f.puts "#{special}   #{message}   #{special}\n\n"
    }
  end

end
