require "option_parser"
require "log"

require "./config"
require "./syncplay/syncplay_bot"
require "./discord_bot"

debug = Log::Severity::Info
path = Path.posix("./config.yaml")

OptionParser.parse do |parser|
  parser.banner = "dmnd bot"

  parser.on "-v", "--version", "Show version" do
    puts "version 0.2.0"
    exit
  end
  parser.on "-f PATH", "--file=PATH", "Config file" do |file_path|
    path = Path.new(file_path)
  end
  parser.on "-d", "--debug", "Verbose logging" do
    debug = Log::Severity::Debug
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
end

begin
  Log.setup(debug)
  Log.info { "Starting up... #{Dir.current}" }

  parser = Config::Parser.new(path)
  syncplay = parser.syncplay

  if syncplay.enabled
    instances = syncplay.instances
    if instances.nil?
      abort "syncplay.instances missing"
    else
      # would be nice to put them in individual threads?
      instances.each do |instance|
        begin
          # this part sucks i wanna know this while parsing
          address = instance.host.hostname.not_nil!
          port = instance.host.port.not_nil!

          bot = Syncplay::Bot.new(
            address,
            port,
            instance.name,
            instance.room
          )
          bot.start
        rescue NilAssertionError
          abort "Host should be in format: 'http://domain.tld:port'"
        end
      end
    end
  end

  discord = parser.discord
  saucenao = parser.saucenao

  plugins = [] of Discord::DiscordPlugin
  if saucenao.enabled
    token = saucenao.token
    if token.nil?
      abort("saucenao.token missing")
    else
      plugins.push(Discord::SaucenaoPlugin.new(token))
    end
  end

  bot = Discord::Bot.new(
    token: discord.token,
    id: discord.id,
    plugins: plugins
  )
  bot.start
rescue ex : ArgumentError | YAML::ParseException
  Log.error { "Couldn't parse config file: \"#{ex.message}\"" }
end
