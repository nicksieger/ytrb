module ExpectTemplate
  def expect_template(template, proc, binding: nil)
    describe template.inspect do
      subject { template }
      if binding
        it { is_expected.to expand_to_with_binding(instance_exec(&proc), binding) }
      else
        it { is_expected.to expand_to(instance_exec(&proc)) }
      end
    end
  end
end
