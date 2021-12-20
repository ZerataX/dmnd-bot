require "yaml"
require "uri"

require "./converter"

module Config
  class Parser
    include YAML::Serializable
    @[YAML::Field(key: "discord")]
    getter discord : Discord
    @[YAML::Field(key: "saucenao")]
    getter saucenao : Saucenao
    @[YAML::Field(key: "syncplay")]
    getter syncplay : Syncplay 

    def self.new(path : Path)
      unless File.exists?(path)
        raise ArgumentError.new "No such file!"
      end
      self.from_yaml File.open(path)
    end
  end

  class Discord
    include YAML::Serializable
    @[YAML::Field(key: "token")]
    getter token : String
    @[YAML::Field(key: "id")]
    getter id : UInt64
  end

  class BotModule
    include YAML::Serializable
    @[YAML::Field(key: "enabled")]
    getter enabled : Bool
  end

  class Syncplay < BotModule
    @[YAML::Field(key: "instances")]
    getter instances : Array(Instance)?
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
  end

  class Saucenao < BotModule
    @[YAML::Field(key: "token")]
    getter token : String?
  end
end
