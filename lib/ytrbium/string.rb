class Ytrbium::String < ::String
  def initialize
    super
    @indent = 0
    @last_newline = 0
  end

  def <<(str)
    @indent = -1 if str.include?("\n")
    super.tap do
      if @indent == -1
        @last_newline = str.rindex("\n")
        @indent = 0
      end
      if @indent == 0 && self[@last_newline..-1] =~ /\n([- ]+)\Z/m
        @indent = $1.length
      end
    end
  end

  def indent_expr(obj)
    obj.bare_yaml.indent_by(@indent)
  end

  def to_s
    if start_with?("---")
      self
    else
      "---\n#{self}"
    end
  end
end
