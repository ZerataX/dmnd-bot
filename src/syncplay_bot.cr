require "./client"
require "./config"
require "option_parser"

debug = false
path = "./config.yaml"


OptionParser.parse do |parser|
  parser.banner = "Syncplay Bot"

  parser.on "-v", "--version", "Show version" do
    puts "version #{SyncplayBot::VERSION}"
    exit
  end
  parser.on "-f PATH", "--file=PATH", "Config file" do |file_path|
    path = file_path
  end
  parser.on "-d", "--debug", "Verbose logging" do
    debug = true
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
  
        bot = SyncplayBot.new(address, port, debug)
        bot.start()
      rescue NilAssertionError
        puts "{ERROR]\t host should be in format: 'http://domain.tld:port'"
      end
    end
  end
rescue ex : ArgumentError
  puts "[ERROR]\t couldn't parse config file: \"#{ex.message}\""
end

