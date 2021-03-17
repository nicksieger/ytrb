require "yaml"
require "erubi"
require "erubi/capture_end"

module Ytrb
  def self.expand(template, binding: nil)
    Ytrb::Engine.new(template).result(binding)
  end
end

require "ytrb/core_ext"
require "ytrb/dsl"
require "ytrb/engine"
require "ytrb/file_resolver"
require "ytrb/string"
require "ytrb/version"
