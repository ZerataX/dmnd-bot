require "yaml"
require "uri"

require "./converter"

module Config
  enum WebhookType
    Matrix
    Discord

    def to_json(io)
      io << '"'
      to_s(io)
      io << '"'
    end
  end

  class Webhook
    include YAML::Serializable
    @[YAML::Field(key: "url", converter: StringToURI)]
    getter url : URI
    @[YAML::Field(key: "type")]
    getter type : WebhookType
  end

  class Instance
    include YAML::Serializable
    @[YAML::Field(key: "host", converter: StringToURI)]
    getter host : URI
    @[YAML::Field(key: "room")]
    getter room : String
    @[YAML::Field(key: "password")]
    getter password : String?
    @[YAML::Field(key: "name")]
    getter name : String
    @[YAML::Field(key: "webhooks")]
    getter webhooks : Array(Webhook)
  end

  class Parser
    include YAML::Serializable
    @[YAML::Field(key: "instances")]
    getter instances : Array(Instance)

    def self.new(path : Path)
      unless File.exists?(path)
        raise ArgumentError.new "No such file!"
      end
      self.from_yaml File.open(path)
    end
  end
end
