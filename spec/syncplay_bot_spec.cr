require "./spec_helper"

DIR          = "./spec"
EXAMPLES_DIR = "#{DIR}/examples"
CERT_DIR     = "#{DIR}/test_certs"
ADDRESS      = "localhost"

describe Config do
  describe Config::Parser do
    it "raises YAML::ParseException when property is missing" do
      expect_raises(YAML::ParseException) do
        parser = Config::Parser.new("#{EXAMPLES_DIR}/bad_config1.yaml")
      end
    end
    # it "raises ArgumentError when url ('port' is missing) is misformatted" do
    #   expect_raises(ArgumentError) do
    #     parser = Config::Parser.new("#{EXAMPLES_DIR}/bad_config2.yaml")
    #   end
    # end
    it "raises YAML::ParseException when type is wrong" do
      expect_raises(YAML::ParseException) do
        parser = Config::Parser.new("#{EXAMPLES_DIR}/bad_config3.yaml")
      end
    end
    it "raises YAML::ParseException when file is misformated" do
      expect_raises(YAML::ParseException) do
        parser = Config::Parser.new("#{EXAMPLES_DIR}/bad_config4.yaml")
      end
    end
    it "raises ArgumentError when path is wrong" do
      expect_raises(ArgumentError) do
        parser = Config::Parser.new("#{EXAMPLES_DIR}/not_there.yaml")
      end
    end

    it "parses the correct values" do
      parser = Config::Parser.new("./config.example.yaml")
      instance = parser.instances[0]
      instance.host.port.should eq(8995)
      type = instance.webhooks[0].type
      type.should eq(Config::WebhookType::Discord)
    end
  end
end

describe SyncplayBot do
  describe "#supports_tls" do
    it "returns true if server support TLS", tags: "server" do
      port = Random.rand(1001..9000)
      server = Process.new("syncplay-server --port #{port} --tls=#{CERT_DIR}", shell: true)
      sleep(1)

      bot = SyncplayBot.new(ADDRESS, port)
      TCPSocket.open(bot.address, bot.port) do |client|
        bot.supports_tls(client).should be_true
      end

      server.terminate
    end

    it "returns false if server doesn't support TLS", tags: "server" do
      port = Random.rand(1001..9000)
      server = Process.new("syncplay-server --port #{port}", shell: true)
      sleep(1)

      bot = SyncplayBot.new(ADDRESS, port)
      TCPSocket.open(bot.address, bot.port) do |client|
        bot.supports_tls(client).should be_false
      end

      server.terminate
    end
  end
end
