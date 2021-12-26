require "./spec_helper"

CERT_DIR     = DIR/"test_certs"
ADDRESS      = "localhost"

describe Syncplay, tags: "syncplay" do
  describe "#supports_tls", tags: "network" do
    it "returns true if server support TLS", tags: "server" do
      port = Random.rand(1025..9000)
      cert_path = Path[CERT_DIR/"chain.pem"]
      unless File.exists? cert_path
        fail("certs were not created, run ./#{CERT_DIR.normalize}/create_certs.sh to create them")
      end
      server = Process.new("syncplay-server --port #{port} --tls=#{CERT_DIR.normalize}", shell: true)
      sleep(1) # wait for server to turn on

      bot = Syncplay::Bot.new(ADDRESS, port, "test", "test")
      TCPSocket.open(bot.address, bot.port) do |client|
        bot.supports_tls(client).should be_true
      end

      server.terminate
    end

    it "returns false if server doesn't support TLS", tags: "server" do
      port = Random.rand(1025..9000)
      server = Process.new("syncplay-server --port #{port}", shell: true)
      sleep(1) # wait for server to turn on

      bot = Syncplay::Bot.new(ADDRESS, port, "test", "test")
      TCPSocket.open(bot.address, bot.port) do |client|
        bot.supports_tls(client).should be_false
      end

      server.terminate
    end
  end
end
