require "pathname"

class Ytrb::FileResolver
  def initialize(root = Dir.getwd)
    @paths = [root, *$LOAD_PATH].map { |p| Pathname.new(p) }
  end

  def expand_path(name)
    path = @paths.detect { |path| (path + name).exist? }
    raise ArgumentError, "No file #{name} found" unless path
    (path.expand_path + name).to_s
  end

  def load(name)
    filename = expand_path name
    File.open(filename, "r") { |file| yield file, filename }
  end
end
