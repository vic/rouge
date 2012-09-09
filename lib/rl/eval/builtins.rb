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

  def list(context, *elements)
    elements.map {|f| RL.eval context, f}
  end

  def fn(context, argv, *body)
    context = RL::Eval::Context.new context

    if argv[-2] == :&
      rest = argv[-1]
      argv = argv[0...-2]
    else
      rest = nil
    end

    lambda {|*args|
      if !rest and argv.length != args.length
        raise ArgumentError,
            "wrong number of arguments (#{args.length} for #{argv.length})"
      end
    }
  end
end

# vim: set sw=2 et cc=80:
