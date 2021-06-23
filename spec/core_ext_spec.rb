RSpec.describe 'Object#indented_yaml' do
  it 'indents a hash by the specified amount' do
    expect({'a' => 1, 'b' => 2}.indented_yaml(4)).to eq("a: 1\n    b: 2\n")
  end

  it 'indents an array by the specified amount' do
    expect([1, 2, 3].indented_yaml(5)).to eq("- 1\n     - 2\n     - 3\n")
  end

  it 'does not indent nil' do
    expect(nil.indented_yaml(2)).to eq('')
  end
end

RSpec.describe 'Object#bare_yaml' do
  it 'renders a hash with no prefix' do
    expect({'a' => 'b', 'c' => 'd'}.bare_yaml).to eq("a: b\nc: d\n")
  end

  it 'renders an array with no prefix' do
    expect(['a', 'b', 'c', 'd'].bare_yaml).to eq("- a\n- b\n- c\n- d\n")
  end

  it 'renders a string with no --- prefix and suffix' do
    expect('a'.bare_yaml).to eq('a')
  end

  it 'renders an empty hash as the empty string' do
    expect({}.bare_yaml).to eq('')
  end

  it 'renders an empty array as the empty string' do
    expect([].bare_yaml).to eq('')
  end

  it 'renders nil as the empty string' do
    expect(nil.bare_yaml).to eq('')
  end

  it 'renders any object that is not present? as the empty string' do
    obj = Object.new
    def obj.present?
      false
    end
    expect(obj.bare_yaml).to eq('')
  end
end

RSpec.describe 'Object#present?' do
  it { expects(Object.new).to be_present }
end

RSpec.describe 'FalseClass#present?' do
  it { expects(false).to_not be_present }
end

RSpec.describe 'NilClass#present?' do
  it { expects(nil).to_not be_present }
end

RSpec.describe 'Array#present?' do
  it { expects([1]).to be_present }
  it { expects([]).to_not be_present }
end

RSpec.describe 'Hash#present?' do
  it { expects({a: 1}).to be_present }
  it { expects({}).to_not be_present }
end

RSpec.describe 'String#indent_by' do
  it { expects('a'.indent_by(2)).to eq('a') }
  it { expects("a\nb\nc".indent_by(2)).to eq("a\n  b\n  c") }
end
