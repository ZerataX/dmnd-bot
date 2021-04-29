require "json"
require "socket"
require "uri"

require "./formatter"
require "./protocol"
require "./config"

module SyncplayBot
  VERSION = "0.1.3"

  class Bot
    getter debug : Format::Levels = Format::Levels::INFO
    getter address : String = "localhost"
    getter port : Int32 = 8995
    getter name : String
    getter room : String

    def initialize(@address, @port, @name, @room, @debug)
    end

    def c_put(message)
      Format.debug "Client >> #{message}", @debug
    end

    def s_put(message)
      Format.debug "Server << #{message}", @debug
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
          Format.info "Listening on #{address}:#{port}", @debug
          if supports_tls(client)
            Format.info "Server supports TLS", @debug
          else
            Format.info "Server does NOT supports TLS", @debug
          end

          user = Syncplay::User.new(@name, @room)

          message = "{\"Hello\": #{user.to_json}}\r\n"
          c_put message
          client << message

          response = client.gets
          s_put response
        end
      rescue Socket::ConnectError
        Format.error "Couldn't connect to #{address}:#{port}", @debug
      end
    end
  end
end
