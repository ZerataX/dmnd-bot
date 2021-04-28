require "yaml"
require "uri"
require "./converter"

module Config
    enum WebhookType
        Matrix
        Discord

        def to_json(io)
            io << '"'
            to_s(io)
            io << '"'
          end
    end
    
    class Webhook
        YAML.mapping({
            url: String,
            type: WebhookType
        })
    end

    class Instance
        YAML.mapping({
            host: {type: URI, converter: StringToURI},
            room: String,
            password: {type: String, optional: true}
            name: String,
            webhooks: Array(Webhook)
        })
    end

    class Parser
        YAML.mapping({
            instances: Array(Instance)
        })

        def self.new(path : String)
            self.from_yaml File.open(path)            
        end
    end
end