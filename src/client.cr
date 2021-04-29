require "json"
require "socket"

require "uri"
require "./formatter"
require "./protocol"

class SyncplayBot
  VERSION = "0.1.0"
  getter debug : Format::Levels = Format::Levels::INFO
  getter address : String = "localhost"
  getter port : Int32 = 8995

  def initialize(@address, @port, debug = false)
    if debug
      @debug = Format::Levels::DEBUG
    end
    Format.debug("listening on #{address}:#{port}", @debug)
  end

  def c_put(message)
    Format.debug("Client >> #{message}", @debug)
  end

  def s_put(message)
    Format.debug("Server << #{message}", @debug)
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
    TCPSocket.open(@address, @port) do |client|
      if supports_tls(client)
        Format.info "Server supports TLS"
      else
        Format.info "Server does NOT supports TLS"
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
