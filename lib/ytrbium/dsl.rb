module Ytrbium
  module DSL
    def file_resolver
      @file_resolver ||= FileResolver.new
    end

    def engine(input = nil, options = {})
      @engine = nil if input
      @engine ||= Engine.new(input, options)
    end

    def expand(binding = nil)
      engine.expand(binding)
    end

    def call(options = {})
      YAML.safe_load expand(binding)
    end

    def expand_path(name)
      file_resolver.expand_path name
    end

    def import(name, as: nil, **options)
      mod = Ytrbium.dsl
      file_resolver.load(name) do |io, filename|
        engine(io.read, filename: filename, module: mod)
      end
      if as
        define_method(as) { mod }
      else
        mod.call(options || {})
      end
    end
  end
end
