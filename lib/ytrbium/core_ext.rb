class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end

  # Indents all but the first line in the emitted yaml by the specified number of
  # spaces.
  def indented_yaml(preindent)
    return "" unless present?
    bare_yaml.indent_by(preindent)
  end

  # Strip `---\n` header and `\n...\n` trailer from yaml, handle different
  # versions of libyaml, see https://tickets.puppetlabs.com/browse/PUP-9313 and
  # related links
  # - libyaml 0.1.7 emits a `\n...\n` end-of-stream trailer, but 0.2.1 does not
  # - treat single-line scalars separately to trim the trailing newline *only*
  #   when the emitted yaml is a single line.
  def bare_yaml
    return "" unless present?
    yaml = to_yaml

    # Detect single-line libyaml 0.2.1 scalar and remove trailing newline
    return yaml.sub(/\A--- ([^\n]+)\n\Z/m, '\1') if yaml.single_line_ending_in_newline?

    yaml.sub(/\A---[ \n]/, "") # Handle header for multi-line yaml snippets
      .sub(/(\n\.\.\.\n)?\Z/m, "") # Handle libyaml 0.1.7 end of stream marker
  end
end

class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class TrueClass
  def blank?
    false
  end
end

class String
  def indent_by(preindent)
    indent_str = " " * preindent
    lines.join(indent_str)
  end

  def single_line_ending_in_newline?
    count("\n") == 1 && self[-1] == "\n"
  end
end
