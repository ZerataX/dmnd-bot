require "option_parser"

OptionParser.parse do |parser|
  parser.banner = "Syncplay Bot"

  parser.on "-v", "--version", "Show version" do
    puts "version #{{{`shards version #{__DIR__}`.stringify}}}"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end
