require "yaml"
require "erubi"
require "erubi/capture_end"

module Ytrbium
  def self.expand(template, binding: nil)
    Ytrbium::Engine.new(template).result(binding)
  end
end

require "ytrbium/core_ext"
require "ytrbium/dsl"
require "ytrbium/engine"
require "ytrbium/file_resolver"
require "ytrbium/string"
require "ytrbium/version"
