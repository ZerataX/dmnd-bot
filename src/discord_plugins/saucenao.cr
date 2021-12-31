require "uri"
require "json"

require "discordcr"

require "./discord_plugin"

module Saucenao
  enum IndexSite
    H_mags                # 0
    Disabled_h_anime      # 1
    Hcg                   # 2
    Disabled_ddb_objects  # 3
    Disabled_ddb_samples  # 4
    Pixiv                 # 5
    Pixivhistorical       # 6
    Disabled_anime        # 7
    Seiga_illust          # 8
    Danbooru              # 9
    Drawr                 # 10
    Nijie                 # 11
    Yandere               # 12
    Disabled_animeop      # 13
    Disabled_IMDb         # 14
    Disabled_Shutterstock # 15
    FAKKU                 # 16
    Reserved              # 17
    Nhentai               # 18
    TwoD_market           # 19
    Medibang              # 20
    Anime                 # 21
    H_Anime               # 22
    Movies                # 23
    Shows                 # 24
    Gelbooru              # 25
    Konachan              # 26
    Sankaku               # 27
    Anime_pictures        # 28
    E621                  # 29
    Idol_complex          # 30
    Bcy_illust            # 31
    Bcy_cosplay           # 32
    Portalgraphics        # 33
    DA                    # 34
    Pawoo                 # 35
    Madokami              # 36
    Mangadex              # 37
    Ehentai               # 38
    ArtStation            # 39
    FurAffinity           # 40
    Twitter               # 41
    Furry_Network         # 42

    Mangadex1 = 371 # 371

    def to_json(io)
      io << '"'
      to_s(io)
      io << '"'
    end
  end

  class Parser
    include JSON::Serializable
    # @[JSON::Field(key: "header")]
    # getter header : Header
    @[YAML::Field(key: "results")]
    getter results : Array(Result)
  end

  class Result
    include JSON::Serializable
    @[JSON::Field(key: "header")]
    getter header : ResultHeader
    @[YAML::Field(key: "data")]
    getter data : ResultData
  end

  class ResultHeader
    include JSON::Serializable
    @[JSON::Field(key: "similarity", converter: StringToFloat)]
    getter similarity : Float32
    @[YAML::Field(key: "thumbnail")]
    getter thumbnail : String
    @[JSON::Field(key: "index_id", converter: Enum::ValueConverter(Saucenao::IndexSite))]
    getter index_id : IndexSite
    @[YAML::Field(key: "index_name")]
    getter index_name : String
    @[JSON::Field(key: "dupes")]
    getter dupes : Int32
    @[YAML::Field(key: "hidden")]
    getter hidden : Int32
  end

  class ResultData
    include JSON::Serializable
    @[JSON::Field(key: "ext_urls")]
    getter ext_urls : Array(String)?

    # optional stuff
    @[JSON::Field(key: "title")]
    getter title : String?
    @[YAML::Field(key: "created_at", converter: StringToDate)]
    getter created_at : Time?
    @[JSON::Field(key: "author_name")]
    getter author_name : String?
    @[JSON::Field(key: "author_url", converter: StringToURI)]
    getter author_url : URI?

    @[JSON::Field(key: "creator")]
    getter creator : Array(String)? | String?

    @[JSON::Field(key: "member_name")]
    getter member_name : String?
    @[JSON::Field(key: "member_id")]
    getter member_id : Int32?
    @[JSON::Field(key: "member_link_id")]
    getter member_link_id : Int32?

    # # Twitter
    @[JSON::Field(key: "tweet_id")]
    getter tweet_id : String?
    @[JSON::Field(key: "tweet_user_id")]
    getter tweet_user_id : String?
    @[JSON::Field(key: "tweet_user_handle")]
    getter tweet_user_handle : String?

    # # Pawoo
    @[JSON::Field(key: "pawoo_id")]
    getter pawoo_id : Int32?
    @[JSON::Field(key: "pawoo_user_username")]
    getter pawoo_user_username : String?
    @[JSON::Field(key: "pawoo_user_acct")]
    getter pawoo_user_acct : String?
    @[JSON::Field(key: "pawoo_user_displayname")]
    getter pawoo_user_displayname : String?

    # # Booru
    @[JSON::Field(key: "danbooru_id")]
    getter danbooru_id : Int32?
    @[JSON::Field(key: "material")]
    getter material : String?
    @[JSON::Field(key: "characters")]
    getter characters : String?
    @[JSON::Field(key: "source")]
    getter source : String?

    # # DeviantArt
    @[JSON::Field(key: "da_id")]
    getter da_id : String?

    # # Pixiv
    @[JSON::Field(key: "pixiv_id")]
    getter pixiv_id : Int32?

    # # Furafinity
    @[JSON::Field(key: "fa_id")]
    getter fa_id : Int32?

    # # Furrynetwork
    @[JSON::Field(key: "fn_id")]
    getter fn_id : Int32?
    @[JSON::Field(key: "fn_type")]
    getter fn_type : Int32?

    # # E-hentai
    @[JSON::Field(key: "eng_name")]
    getter eng_name : String?
    @[JSON::Field(key: "jap_name")]
    getter jap_name : String?

    # # bcy.net
    @[JSON::Field(key: "bcy_id")]
    getter bcy_id : Int32?
    @[JSON::Field(key: "bcy_type")]
    getter bcy_type : String?

    # # Seiga
    @[JSON::Field(key: "seiga_id")]
    getter seiga_id : Int32?

    # # Anime
    @[JSON::Field(key: "anidb_aid")]
    getter anidb_aid : Int32?
    @[JSON::Field(key: "mal_id")]
    getter mal_id : Int32?
    @[JSON::Field(key: "anilist_id")]
    getter anilist_id : Int32?
    @[JSON::Field(key: "part")]
    getter part : String?
    @[JSON::Field(key: "year")]
    getter year : String?
    @[JSON::Field(key: "est_time")]
    getter est_time : String?
  end
end

module Discord
  class SaucenaoPlugin < DiscordPlugin
    @api_endpoint = URI.new
    @api_params = URI::Params.new
    @endpoint : URI = URI.new
    @params = URI::Params.new
    
    def initialize(token : String)
      @endpoint = URI.parse "https://saucenao.com/search.php"
      @api_endpoint = @endpoint.dup
      @params == URI::Params{
        "output_type" => "0",
        "dedupe"      => "2",
      }
      @api_params = @params.clone
      @api_params.add("api_key", token)
      @api_params["output_type"] = "2"
      @endpoint.query_params = @params
      @api_endpoint.query_params = @api_params
      super(name: "SauceNAO", passive: true)
    end

    def passive(client, payload)
      images = 0

      payload.attachments.each do |attachment|
        url = attachment.url
        sauce = get_sauce url

        if sauce.nil?
          Log.info { "no sauce :("}
          next
        end
        Log.info { "got sauce!" }
        embed = construct_embed(sauce, url, threshold: 80.0)
        unless embed.nil?
          client.create_message(payload.channel_id, embed: embed, content: "")
        end
      end
    end

    def construct_embed(sauce : Saucenao::Parser, url : String, limit : Int32 = 2, threshold : Float64 = 0) : Embed?
      unless @params.includes? "url"
        @params.add("url", url)
      end
      @params["url"] = url
      @endpoint.query_params = @params

      embed = Embed.new(title: "Sauce found!", url: @endpoint.to_s)
      fields = [] of EmbedField
      
      if sauce
        Log.info { "found #{sauce.results.size} sources!" }
        sauce.results.sort_by! { |result| result.header.similarity }
        sauce.results.reverse!
        sauce.results[..(limit - 1)].each do |result|
          data = result.data
          header = result.header
          similarity = header.similarity

          case similarity
          when 0..60
            similarity_emoji = "🔴"
          when 60..80
            similarity_emoji = "🟠"
          when 80..90
            similarity_emoji = "🟡"
          when 90..
            similarity_emoji = "🟢"
          end


          field_value = ""
          case header.index_id
          when Saucenao::IndexSite::Anime
            field_value += "🎞️ #{data.source} Episode #{data.part} - #{data.est_time}\n"
            threshold *= 0.65 # anime screenshots are accurate even at very low similarity
          end

          urls = data.ext_urls
          unless urls.nil?
            urls.each { |url| field_value += "- <#{url}>\n" }
          end

          field = EmbedField.new(
            name: "#{similarity_emoji} Similiarity #{similarity}%",
            value: field_value
          )  

          if similarity < threshold
            Log.info { "Threshold not met!" }
            next
          end

          fields.push(field)


          if embed.thumbnail.nil? && !header.thumbnail.nil?
            embed.thumbnail = EmbedThumbnail.new header.thumbnail
          end
        end
      end
      if fields.size > 0
        embed.fields = fields
        embed
      else
        nil
      end
    end

    def get_sauce(url : URI | String) : Saucenao::Parser | Nil
      unless @api_params.includes? "url"
        @api_params.add("url", url)
      end
      @api_params["url"] = url
      @api_endpoint.query_params = @api_params

      Log.info { "getting sauce for: #{@api_endpoint}" }

      response = HTTP::Client.get @api_endpoint
      if response.status_code == 200
        begin
          Saucenao::Parser.from_json response.body
        rescue exception : JSON::SerializableError
          Log.error(exception: exception) { "Could not decode json!" }
          Log.error { response.body }
        end
      else
        Log.warn { "Saucenao responded with #{response.status_code}" }
        nil
      end
    end
  end
end
