require "json"
require "socket"
require "uri"
require "log"

require "./syncplay_protocol"

module Syncplay
  class Bot
    getter address : String = "localhost"
    getter port : Int32 = 8995
    getter name : String
    getter room : String

    def initialize(@address, @port, @name, @room)
    end

    def c_put(message)
      Log.debug { "Client >> #{message}" }
    end

    def s_put(message)
      Log.debug { "Server << #{message}" }
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
        raise RuntimeError.new "Server didn't respond to TLS request"
      end
    end

    def start
      begin
        TCPSocket.open(@address, @port) do |client|
          Log.info { "Listening on #{address}:#{port}" }
          if supports_tls(client)
            Log.info { "Server supports TLS" }
          else
            Log.info { "Server does NOT supports TLS" }
          end

          user = Syncplay::User.new(@name, @room)

          message = "{\"Hello\": #{user.to_json}}\r\n"
          c_put message
          client << message

          response = client.gets
          s_put response
        end
      rescue Socket::ConnectError
        Log.error { "Couldn't connect to #{address}:#{port}" }
      end
    end
  end
end
