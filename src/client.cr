require "json"
require "socket"

require "./protocol"

PORT = 8995
ADDRESS = "localhost"


def c_put(message)
    puts "Client >> #{message}"
end

def s_put(message)
    puts "Server << #{message}"
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

TCPSocket.open(ADDRESS, PORT) do |client|
    if supports_tls(client)
        puts "!!! server supports TLS"
    else
        puts "!!! server does NOT supports TLS"
    end

    user = Syncplay::User.new( "memelord", "meme")

    message = "{\"Hello\": #{user.to_json}}\r\n"
    c_put message
    client << message

    response = client.gets
    s_put response
end
