require "spec_helper"
require "ytrbium"

def example_binding(a, b)
  c = true
  binding
end

RSpec.describe Ytrbium do
  expect_template "", -> { eq("---\n") }

  expect_template({"a" => true}.bare_yaml, -> { eq("---\na: true\n") })

  describe "YAML preamble does not get prepended if in the source template" do
    expect_template "--- true\n", -> { eq("--- true\n") }
    expect_template "---\ntrue\n", -> { eq("---\ntrue\n") }
    expect_template "--- {}\n", -> { eq("--- {}\n") }
    expect_template "---\n{}\n", -> { eq("---\n{}\n") }
  end

  describe "with a simple binding" do
    b = example_binding(1, "hello")

    expect_template "a: <%= b %>", -> { eq("---\na: hello") }, binding: b
    expect_template "a: <%= a %>\nb: <%= b %>\nc: <%= c %>", -> { eq("---\na: 1\nb: hello\nc: true") }, binding: b
  end

  describe "auto indentation" do
    expect_template "top:\n  <%= { 'a' => 1, 'b' => 2, 'c' => 3 } %>", -> { eq("---\ntop:\n  a: 1\n  b: 2\n  c: 3\n") }
    expect_template "top:\n  <%= { 'sub' => { 'a' => 1, 'b' => 2, 'c' => 3 }, 'end' => true } %>", -> { eq("---\ntop:\n  sub:\n    a: 1\n    b: 2\n    c: 3\n  end: true\n") }
  end

  describe "define a regular, non-templating method with arguments" do
    template = <<~TEMPL
      <% def numbers(times)
           (1..times).to_a
         end -%>
      msg:
      <%= numbers(5) -%>
    TEMPL
    expect_template template, -> do
      eq(<<~EXP)
        ---
        msg:
        - 1
        - 2
        - 3
        - 4
        - 5
      EXP
    end
  end

  describe "define a template method" do
    template = <<~TEMPL
      <%! def hello() -%>
        Hi!
      <%! end -%>
      msg: <%= hello %>
    TEMPL

    expect_template template, -> do
      eq(<<~EXP)
        ---
        msg: Hi!
      EXP
    end
  end

  describe "define a template method with arguments" do
    template = <<~TEMPL
      <%! def hello(times) -%>
        <% times.times do |n| -%>
        - Hi <%= n + 1 %>!
        <% end -%>
      <%! end -%>
      msg:
      <%= hello(4) -%>
    TEMPL

    expect_template template, -> do
      eq(<<~EXP)
        ---
        msg:
        - Hi 1!
        - Hi 2!
        - Hi 3!
        - Hi 4!
      EXP
    end
  end

  let(:static_resources_expected) { <<~EXP }
    ---
    static_resources:
      listeners:
      - address:
          socket_address:
            protocol: TCP
            address: 127.0.0.1
            port: 8080
        traffic_direction: INBOUND
      - address:
          socket_address:
            protocol: TCP
            address: 127.0.0.1
            port: 9090
        traffic_direction: OUTBOUND
  EXP

  describe "use a template method multiple times" do
    template = <<~TEMPL
      <%! def address(proto, addr, port) -%>
      address:
        socket_address:
          protocol: <%= proto %>
          address: <%= addr %>
          port: <%= port %>
      <%! end -%>
      static_resources:
        listeners:
        - <%= address('TCP', '127.0.0.1', 8080) -%>
          traffic_direction: INBOUND
        - <%= address('TCP', '127.0.0.1', 9090) -%>
          traffic_direction: OUTBOUND
    TEMPL

    expect_template template, -> do
      eq(static_resources_expected)
    end

    let(:expected) do
      {
        "static_resources" => {
          "listeners" => [
            {
              "address" => {
                "socket_address" => {"protocol" => "TCP", "address" => "127.0.0.1", "port" => 8080}
              },
              "traffic_direction" => "INBOUND"
            },
            {
              "address" => {
                "socket_address" => {"protocol" => "TCP", "address" => "127.0.0.1", "port" => 9090}
              },
              "traffic_direction" => "OUTBOUND"
            }
          ]
        }
      }
    end

    it "parses to the expected object" do
      expect(YAML.safe_load(Ytrbium.expand(template))).to eq(expected)
    end

    describe "with extra whitespace" do
      let(:template) { template.gsub(/-%>/, "%>") }
      it "parses to the expected object" do
        expect(YAML.safe_load(Ytrbium.expand(template))).to eq(expected)
      end
    end
  end

  describe "import" do
    let(:import_template) do
      <<~TEMPL
        <%! def address(proto, addr, port) -%>
        address:
          socket_address:
            protocol: <%= proto %>
            address: <%= addr %>
            port: <%= port %>
        <%! end -%>
      TEMPL
    end

    template = <<~TEMPL
      <% import 'address.template.yaml' -%>
      static_resources:
        listeners:
        - <%= address('TCP', '127.0.0.1', 8080) -%>
          traffic_direction: INBOUND
        - <%= address('TCP', '127.0.0.1', 9090) -%>
          traffic_direction: OUTBOUND
    TEMPL

    before do
      allow_any_instance_of(Ytrbium::FileResolver).to receive(:load).and_yield(StringIO.new(import_template), "address.template.yaml")
    end

    expect_template template, -> do
      eq(static_resources_expected)
    end
  end

  describe "import as:" do
    let(:import_template) do
      <<~TEMPL
        <%! def address(proto, addr, port) -%>
        address:
          socket_address:
            protocol: <%= proto %>
            address: <%= addr %>
            port: <%= port %>
        <%! end -%>
      TEMPL
    end

    template = <<~TEMPL
      <% import 'address.template.yaml', as: :addr -%>
      static_resources:
        listeners:
        - <%= addr.address('TCP', '127.0.0.1', 8080) -%>
          traffic_direction: INBOUND
        - <%= addr.address('TCP', '127.0.0.1', 9090) -%>
          traffic_direction: OUTBOUND
    TEMPL

    before do
      allow_any_instance_of(Ytrbium::FileResolver).to receive(:load).and_yield(StringIO.new(import_template), "address.template.yaml")
    end

    expect_template template, -> do
      eq(static_resources_expected)
    end
  end

  describe "call import" do
    let(:import_template) do
      <<~TEMPL
        address:
          socket_address:
            protocol: <%= options[:proto] || 'TCP' %>
            address: <%= options[:address] || '127.0.0.1' %>
            port: <%= options[:port] %>
      TEMPL
    end

    template = <<~TEMPL
      <% import 'address.template.yaml', as: :addr -%>
      static_resources:
        listeners:
        - <%= addr.(port: 8080) -%>
          traffic_direction: INBOUND
        - <%= addr.(port: 9090) -%>
          traffic_direction: OUTBOUND
    TEMPL

    before do
      allow_any_instance_of(Ytrbium::FileResolver).to receive(:load).and_yield(StringIO.new(import_template), "address.template.yaml")
    end

    expect_template template, -> do
      eq(static_resources_expected)
    end
  end
end
