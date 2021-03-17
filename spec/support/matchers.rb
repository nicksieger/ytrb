RSpec::Matchers.define :expand_to do |expected, &block|
  match do |template|
    @actual = Ytrbium.expand template
    values_match? expected, @actual
  end

  diffable
end

RSpec::Matchers.define :expand_to_with_binding do |expected, binding, &block|
  match do |template|
    @actual = Ytrbium.expand template, binding: binding
    values_match? expected, @actual
  end

  diffable
end
