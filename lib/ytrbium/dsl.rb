module Ytrbium
  module DSL
    def _file_resolver
      @_file_resolver ||= FileResolver.new
    end

    def _engine(input = nil, options = {})
      @_engine = nil if input
      @_engine ||= Engine.new(input, options)
    end

    def expand(binding = nil)
      _engine.expand(binding)
    end

    def call(options = {})
      YAML.safe_load expand(binding)
    end

    def expand_path(name)
      _file_resolver.expand_path name
    end

    def import(name, as: nil, **options)
      mod = Ytrbium.dsl
      _file_resolver.load(name) do |io, filename|
        _engine(io.read, filename: filename, module: mod)
      end
      if as
        define_method(as) { mod }
      else
        mod.call(options || {})
      end
    end
  end
end
