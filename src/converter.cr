# JSON converters
struct StringToBoolConverter(Converter)
  def self.from_json(pull : JSON::PullParser)
    string = pull.read_string
    string == "true"
  end

  def self.to_json(value : Bool, json : JSON::Builder)
    json.bool(value)
  end
end

# YAML converters
struct StringToURI(Converter)
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
