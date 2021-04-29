require "./spec_helper"

EXAMPLES_DIR = DIR/"examples"
ADDRESS      = "localhost"

describe SyncplayBot do
  describe "#supports_tls" do
    it "returns true if server support TLS", tags: "server" do
      port = Random.rand(1025..9000)
      server = Process.new("syncplay-server --port #{port} --tls=#{CERT_DIR.normalize}", shell: true)
      sleep(1) # wait for server to turn on

      bot = SyncplayBot::Bot.new(ADDRESS, port, "test", "test", Format::Levels::NONE)
      TCPSocket.open(bot.address, bot.port) do |client|
        bot.supports_tls(client).should be_true
      end

      server.terminate
    end

    it "returns false if server doesn't support TLS", tags: "server" do
      port = Random.rand(1025..9000)
      server = Process.new("syncplay-server --port #{port}", shell: true)
      sleep(1) # wait for server to turn on

      bot = SyncplayBot::Bot.new(ADDRESS, port, "test", "test", Format::Levels::NONE)
      TCPSocket.open(bot.address, bot.port) do |client|
        bot.supports_tls(client).should be_false
      end

      server.terminate
    end
  end
end
