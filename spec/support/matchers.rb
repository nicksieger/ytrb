RSpec::Matchers.define :expand_to do |expected, &block|
  match do |template|
    @actual = Ytrb.expand template
    values_match? expected, @actual
  end

  diffable
end

RSpec::Matchers.define :expand_to_with_binding do |expected, binding, &block|
  match do |template|
    @actual = Ytrb.expand template, binding: binding
    values_match? expected, @actual
  end

  diffable
end
