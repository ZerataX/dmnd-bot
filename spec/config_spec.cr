require "./spec_helper"

CERT_DIR = DIR/"test_certs"

describe Config do
  describe Config::Parser do
    it "raises YAML::ParseException when property is missing" do
      expect_raises(YAML::ParseException) do
        parser = Config::Parser.new((EXAMPLES_DIR/"bad_config1.yaml").normalize)
      end
    end
    # it "raises ArgumentError when url ('port' is missing) is misformatted" do
    #   expect_raises(ArgumentError) do
    #     parser = Config::Parser.new(EXAMPLES_DIR/"bad_config2.yaml".normalize)
    #   end
    # end
    it "raises YAML::ParseException when type is wrong" do
      expect_raises(YAML::ParseException) do
        parser = Config::Parser.new((EXAMPLES_DIR/"bad_config3.yaml").normalize)
      end
    end
    it "raises YAML::ParseException when file is misformated" do
      expect_raises(YAML::ParseException) do
        parser = Config::Parser.new((EXAMPLES_DIR/"bad_config4.yaml").normalize)
      end
    end
    it "raises ArgumentError when path is wrong" do
      expect_raises(ArgumentError) do
        parser = Config::Parser.new((EXAMPLES_DIR/"not_there.yaml").normalize)
      end
    end

    it "parses the correct values" do
      parser = Config::Parser.new(Path.posix("./config.example.yaml").normalize)
      instance = parser.instances[0]
      instance.host.port.should eq(8995)
      type = instance.webhooks[0].type
      type.should eq(Config::WebhookType::Discord)
    end
  end
end
