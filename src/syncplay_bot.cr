require "./client"
require "./config"
require "option_parser"

debug = Format::Levels::INFO
path = Path.posix("./config.yaml")

OptionParser.parse do |parser|
  parser.banner = "Syncplay Bot"

  parser.on "-v", "--version", "Show version" do
    puts "version #{SyncplayBot::VERSION}"
    exit
  end
  parser.on "-f PATH", "--file=PATH", "Config file" do |file_path|
    path = Path.new(file_path)
  end
  parser.on "-d", "--debug", "Verbose logging" do
    debug = Format::Levels::DEBUG
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

begin
  parser = Config::Parser.new(path)
  if parser.instances
    parser.instances.each do |instance|
      begin
        # this part sucks i wanna know this while parsing
        address = instance.host.hostname.not_nil!
        port = instance.host.port.not_nil!

        bot = SyncplayBot.new(
          address,
          port,
          instance.name,
          instance.room,
          debug
        )
        bot.start
      rescue NilAssertionError
        Format.error "Host should be in format: 'http://domain.tld:port'", debug
      end
    end
  end
rescue ex : ArgumentError | YAML::ParseException
  Format.error "Couldn't parse config file: \"#{ex.message}\"", debug
end
