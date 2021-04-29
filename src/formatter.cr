module Format
  enum Levels
    ERROR
    WARNING
    INFO
    DEBUG
  end

  macro define_method(error_name)
        def Format.{{error_name.id.downcase}}(msg, level = Levels::INFO)
            if level >= Levels::{{error_name}}
                puts "[#{Levels::{{error_name}}}]:\t #{msg}"
            end
        end
    end

  {% for value in Levels.constants %}
        define_method({{value}})
    {% end %}
end
