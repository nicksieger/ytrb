module Ytrb
  module DSL
    def _file_resolver
      @_file_resolver ||= FileResolver.new
    end

    def call(options = {})
      YAML.safe_load @_engine.result(binding)
    end

    def expand_path(name)
      _file_resolver.expand_path name
    end

    def import(name, as: nil, **options)
      mod = Module.new
      _file_resolver.load(name) do |io, filename|
        Engine.new(io.read, filename: filename, module: mod)
      end
      if as
        define_method(as) { mod }
      else
        mod.call(options || {})
      end
    end
  end
end
