require "json"
require "socket"
require "uri"
require "log"

require "discordcr"

require "./discord_plugins/discord_plugins"

PREFIX = "!!"

module Discord
  class Bot
    getter token : String
    getter id : UInt64
    getter plugins : Array(DiscordPlugin)
    @permissions : Discord::Permissions = Discord::Permissions.new(0)
    @invite_url : URI = URI.parse "https://discord.com/oauth2/authorize"

    def initialize(@token, @id, @plugins)
      @permissions |= Discord::Permissions::ReadMessages |
                      Discord::Permissions::SendMessages |
                      Discord::Permissions::AddReactions |
                      Discord::Permissions::ChangeNickname |
                      Discord::Permissions::ChangeNickname

      params = URI::Params{
        "client_id"   => @id.to_s,
        "permissions" => @permissions.to_json,
        "scope"       => "bot",
      }
      @invite_url.query_params = params
    end

    def start
      client = Discord::Client.new(token: "Bot #{@token}", client_id: @id)
      cache = Discord::Cache.new(client)
      client.cache = cache
      Log.info { "invite url: #{@invite_url}" }

      client.on_message_create do |payload|
        command = payload.content.split(" ")[0]
        case command
        when PREFIX + "ping"
          # We first create a new Message, and then we check how long it took to send the message by comparing it to the current time
          m = client.create_message(payload.channel_id, "Pong!")
          time = Time.utc - payload.timestamp
          client.edit_message(m.channel_id, m.id, "Pong! Time taken: #{time.total_milliseconds} ms.")
        end

        plugins.each do |plugin|
          plugin.commands.includes? command
          command = command.lchop(PREFIX)
          plugin.execute(command, client, payload)
        end
      end

      client.run
    end
  end
end
