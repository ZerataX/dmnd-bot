require "./converter"

module Syncplay
  class Version
    getter major : UInt16
    getter minor : UInt16
    getter patch : UInt16

    def initialize(@major : UInt16, @minor : UInt16, @patch : UInt16)
    end

    def initialize(version : String)
      @major, @minor, @patch = version.split(".").map { |x| x.to_u16 }
    end

    def self.new(pull : JSON::PullParser)
      new pull.read_string
    end

    def to_json(json : JSON::Builder)
      json.string("#{@major}.#{@minor}.#{@patch}")
    end
  end

  class TLSenabled
    include JSON::Serializable
    @[JSON::Field(key: "startTLS", converter: StringToBoolConverter)]
    getter startTLS : Bool
  end

  class Features
    include JSON::Serializable
    @[JSON::Field(key: "sharedPlaylists")]
    getter sharedPlaylists : Bool = true
    @[JSON::Field(key: "chat")]
    getter chat : Bool = true
    @[JSON::Field(key: "featureList")]
    getter featureList : Bool = true
    @[JSON::Field(key: "readiness")]
    getter readiness : Bool = true
    @[JSON::Field(key: "managedRooms")]
    getter managedRooms : Bool = true

    def initialize # @sharedPlaylists : Bool = true,
      # @chat : Bool = true,
      # @featureList : Bool = true,
      # @readiness : Bool = true,
      # @managedRooms : Bool = true
    end
  end

  class Room
    include JSON::Serializable
    @[JSON::Field(key: "name")]
    getter name : String

    def initialize(@name)
    end
  end

  class User
    include JSON::Serializable
    @[JSON::Field(key: "username")]
    getter username : String
    @[JSON::Field(key: "room")]
    getter room : Room
    @[JSON::Field(key: "version")]
    getter version : Version = Version.new("1.2.255")
    @[JSON::Field(key: "realversion")]
    getter realversion : Version = Version.new("1.6.8")
    @[JSON::Field(key: "features")]
    getter features : Features = Features.new

    def initialize(@username : String, roomname : String)
      @room = Room.new roomname
    end
  end
end
