module Syncplay
    struct StringToBoolConverter(Converter)
        def self.from_json(pull : JSON::PullParser)
        string = pull.read_string
        string == "true"
        end

        def self.to_json(value : Bool, json : JSON::Builder)
            json.bool(value)
        end
    end

    class Version
        getter major : UInt16
        getter minor : UInt16
        getter patch : UInt16
    
        def initialize (@major : UInt16, @minor : UInt16, @patch : UInt16)
        end
    
        def initialize (version : String)
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
        JSON.mapping(
            startTLS: {type: Bool, converter: StringToBoolConverter}
        )
    end

    class Features
        JSON.mapping(
            "sharedPlaylists": {type: Bool, default: true},
            "chat": {type: Bool, default: true},
            "featureList": {type: Bool, default: true},
            "readiness": {type: Bool, default: true},
            "managedRooms": {type: Bool, default: true}
        )
    end

    class Room
        JSON.mapping(
            name: String
        )

        def initialize(@name : String)
        end
    end

    class User
        JSON.mapping(
            username: String,
            room: Room,
            version: {type: Version, default: Version.new("1.2.255")},
            realversion: {type: Version, default: Version.new("1.6.8")},
            # features: {type: Features, default: Features}
        )

        def initialize(@username : String, roomname : String)
            @room = Room.new roomname
            @version = Version.new("1.2.255")
            @realversion = Version.new("1.6.8")
        end
    end
end
