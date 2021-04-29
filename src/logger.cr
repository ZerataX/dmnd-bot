module Logger
  enum Levels
    ERROR
    WARNING
    INFO
    DEBUG
  end

  macro define_method(error_name)
        def Logger.{{error_name.id.downcase}}(msg, level = Levels::INFO)
            if level > Levels::INFO
                "[#{Levels::{{error_name}}}]:\t #{msg}"
            end
        end
    end

  {% for value in Levels.constants %}
        define_method({{value}})
    {% end %}
end
