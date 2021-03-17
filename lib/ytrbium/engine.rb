class Ytrbium::Engine < Erubi::CaptureEndEngine
  def initialize(input, options = {})
    @template_module = options[:module] || Ytrbium.dsl
    stack_var = @defstack = "@_ybuf_stack"
    engine = self
    @template_module.module_eval do
      instance_variable_set(:@_engine, engine)
      instance_variable_set(stack_var.to_sym, [])
    end
    bufvar = "@_ybuf"
    bufval = "Ytrbium::String.new"
    super(input, options.merge(bufval: bufval,
                               bufvar: bufvar,
                               preamble: "options ||= {}; #{bufvar} = #{bufval};",
                               escape: true,
                               escapefunc: "@_ybuf.indent_expr",
                               regexp: /<%(\|?={1,2}|!|-|\#|%|\|)?(.*?)([-=])?%>([ \t]*\r?\n)?/m))
  end

  def expand(b = nil)
    mod_src = src
    args = []
    args.unshift @filename, 1 if @filename
    args.unshift b if b
    @template_module.module_eval do
      # rubocop:disable Security/Eval
      eval(mod_src, *args)
      # rubocop:enable Security/Eval
    end
  end

  private

  def handle(indicator, code, tailch, rspace, lspace)
    case indicator
    when "!"
      rspace = nil if tailch && !tailch.empty?
      add_text(lspace) if lspace

      if code.strip == "end"
        src << "YAML.safe_load(#{@bufvar}.to_s); ensure; #{@bufvar} = #{@defstack}.pop; end;"
      else
        src << code << "; #{@defstack} << #{@bufvar}; #{@bufvar} = #{@bufval}; "
      end

      add_text(rspace) if rspace
    else
      super
    end
  end
end
