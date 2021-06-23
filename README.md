# Ytrbium

Ytrbium is a simple YAML+ERB templating library in Ruby. With Ytrbium:

- Generate large, verbose YAML files from reusable templates. 
- Collect and organize reusable template methods in multiple files and `import` them into each template.
- Indent template items correctly and intuitively.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ytrbium'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ytrbium

## Usage

Basic usage is demonstrated by a simple example:

```ruby
require "ytrbium"
template = <<~TEMPL
  <%! def hello(times) -%>
    <% times.times do |n| -%>
    - Hi <%= n + 1 %>!
    <% end -%>
  <%! end -%>
  msg:
  <%= hello(options[:count] || 4) -%>
TEMPL

Ytrbium.expand(template)
# =>
#  msg:
#  - Hi 1
#  - Hi 2
#  - Hi 3
#  - Hi 4

options = { count: 2 }
puts Ytrbium.expand(template, binding: binding)
# =>
#  msg:
#  - Hi 1
#  - Hi 2
```

A Ytrbium template is an [ERB template](https://ruby-doc.org/stdlib-2.7.1/libdoc/erb/rdoc/ERB.html) over a YAML document with some additional YAML-specific functionality:

1. You can declare re-usable functions in the template
2. You can split templates across files and `import` them into a main template
3. Every line of each dynamic ERB tag's content is indented correctly in its surroundings, which enables you to apply 1. and 2. with impunity and not worry that your resulting document is structured incorrectly.

Expanding the previous example:

examples/hello.template.yaml:
```yaml
<%! def hello(times) -%>
  <% times.times do |n| -%>
  - Hi <%= n + 1 %>!
  <% end -%>
<%! end -%>
```

examples/main.template.yaml:
```yaml
<% import 'hello.template.yaml' -%>
one_message:
  <%= hello(1) -%>
  - final_messages:
    <%= hello(2) -%>
```

Run the `ytrbium` command on the main template:
```
ytrbium examples/main.template.yaml
---
one_message:
  - Hi 1!
  - final_messages:
    - Hi 1!
    - Hi 2!
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nicksieger/ytrbium. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/nicksieger/ytrbium/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ytrbium project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nicksieger/ytrbium/blob/master/CODE_OF_CONDUCT.md).
