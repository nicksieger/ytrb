require "yaml"
require "erubi"
require "erubi/capture_end"

module Ytrbium
  def self.expand(template, binding: nil)
    dsl.engine(template).expand(binding)
  end

  def self.dsl
    resolver = file_resolver
    Module.new do
      @file_resolver = resolver
      include Ytrbium::DSL
      extend self
    end
  end

  def self.paths
    file_resolver.paths
  end

  def self.paths=(paths)
    file_resolver.paths = paths
  end

  def self.file_resolver
    @file_resolver ||= FileResolver.new
  end
end

require "ytrbium/file_resolver"
require "ytrbium/core_ext"
require "ytrbium/dsl"
require "ytrbium/engine"
require "ytrbium/string"
require "ytrbium/version"
