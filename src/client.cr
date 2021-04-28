require "json"
require "socket"

require "uri"
require "./protocol"


class SyncplayBot
    VERSION = "0.1.0"
    getter debug : Bool = false
    getter address : String = "localhost"
    getter port : Int32 = 8995

    def initialize (@address, @port , @debug)
    end

    def c_put(message)
        puts "[DEBUG]\t Client >> #{message}" if @debug
    end
    
    def s_put(message)
        puts "[DEBUG]\t Server << #{message}" if @debug
    end

    def supports_tls(client)
        message = %({"TLS": {"startTLS": "send"}}\r\n)
        c_put message
        client << message
    
        response = client.gets
        s_put response
        if !response.nil?
            return Syncplay::TLSenabled.from_json(response, "TLS").startTLS
        else
            puts "Error!!"
            return false
        end
    end

    def start()
        TCPSocket.open(@address, @port) do |client|
            if supports_tls(client)
                puts "[INFO]\t Server supports TLS"
            else
                puts "[INFO]\t Server does NOT supports TLS"
            end
        
            user = Syncplay::User.new("memelord", "meme")
        
            message = "{\"Hello\": #{user.to_json}}\r\n"
            c_put message
            client << message
        
            response = client.gets
            s_put response
        end
    end
end