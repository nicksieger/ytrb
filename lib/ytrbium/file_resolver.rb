require "pathname"

class Ytrbium::FileResolver
  attr_reader :paths

  def initialize(paths = nil)
    @paths = paths && Array(paths) || [Dir.getwd]
    init_search
  end

  def paths=(new_paths)
    unless new_paths
      raise ArgumentError,
        "must provide a string path or array of string paths"
    end
    @paths = Array(new_paths)
    init_search
  end

  def expand_path(name)
    path = @search.detect { |path| (path + name).exist? }
    raise ArgumentError, "No file #{name} found" unless path
    (path.expand_path + name).to_s
  end

  def load(name)
    filename = expand_path name
    File.open(filename, "r") { |file| yield file, filename }
  end

  private def init_search
    @search = [*@paths, *$LOAD_PATH].map { |p| Pathname.new(p) }
  end
end
