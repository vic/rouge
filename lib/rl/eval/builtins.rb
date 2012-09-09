# encoding: utf-8

module RL::Eval::Builtins; end

class << RL::Eval::Builtins
  def let(context, bindings, *body)
    context = RL::Eval::Context.new context
    bindings.each_slice(2) do |k, v|
      context.set_here k, RL::Eval.eval(context, v)
    end
    RL.eval context, *body
  end

  def quote(context, form)
    form
  end
end

# vim: set sw=2 et cc=80:
