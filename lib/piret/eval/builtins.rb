# encoding: utf-8

module Piret::Eval::Builtins
  SYMBOLS = {
    :nil => nil,
    :true => true,
    :false => false,
  }
end

class << Piret::Eval::Builtins
  def let(context, bindings, *body)
    context = Piret::Eval::Context.new context
    bindings.each_slice(2) do |k, v|
      context.set_here k, Piret::Eval.eval(context, v)
    end
    Piret.eval context, *body
  end

  def quote(context, form)
    form
  end

  def list(context, *elements)
    elements.map {|f| Piret.eval context, f}
  end

  def fn(context, argv, *body)
    context = Piret::Eval::Context.new context

    if argv[-2] == :&
      rest = argv[-1]
      argv = argv[0...-2]
    else
      rest = nil
    end

    lambda {|*args|
      if !rest ? (args.length != argv.length) : (args.length < argv.length)
        raise ArgumentError,
            "wrong number of arguments (#{args.length} for #{argv.length})"
      end

      (0...argv.length).each do |i|
        context.set_here argv[i], args[i]
      end

      if rest
        context.set_here rest, args[argv.length..-1]
      end

      Piret.eval context, *body
    }
  end

  def def(context, name, form)
    context.ns.set_here name, Piret.eval(context, form)
    :"#{context.ns.name}/#{name}"
  end
end

# vim: set sw=2 et cc=80:
