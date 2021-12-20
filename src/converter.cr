struct StringToBool(Converter)
  def self.from_json(pull : JSON::PullParser)
    string = pull.read_string
    string == "true"
  end

  def self.to_json(value : Bool, json : JSON::Builder)
    json.bool(value)
  end
end

struct StringToFloat(Converter)
  def self.from_json(pull : JSON::PullParser)
    string = pull.read_string
    string.to_f32
  end

  def self.to_json(value : Bool, json : JSON::Builder)
    json.string(value.to_s)
  end
end

struct StringToURI(Converter)
  def self.from_json(pull : JSON::PullParser)
    string = pull.read_string
    URI.parse string
  end

  def self.to_json(value : Bool, json : JSON::Builder)
    json.string(value.to_s)
  end

  def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node) : URI
    unless node.is_a?(YAML::Nodes::Scalar)
      node.raise "Expected scalar, not #{node.kind}"
    end
    URI.parse node.value
  end

  def self.to_yaml(value : URI, yaml : YAML::Builder)
    yaml.string value.to_s
  end
end

struct StringToTime(Converter)
  def self.from_json(pull : JSON::PullParser)
    string = pull.read_string
    Time.parse(string, "%Y-%m-%dT%T.%3NZ", Time::Location::UTC)
  end

  def self.to_json(value : Bool, json : JSON::Builder)
    json.string(value.to_s("%Y-%m-%dT%T.%3NZ"))
  end

  def self.from_yaml(ctx : YAML::ParseContext, node : YAML::Nodes::Node) : Time
    unless node.is_a?(YAML::Nodes::Scalar)
      node.raise "Expected scalar, not #{node.kind}"
    end
    # "2017-10-11T12:29:20.000Z
    Time.parse(node.value, "%Y-%m-%dT%T.%3NZ", Time::Location::UTC)
  end

  def self.to_yaml(value : URI, yaml : YAML::Builder)
    yaml.string value.to_s("%Y-%m-%dT%T.%3NZ")
  end
end
