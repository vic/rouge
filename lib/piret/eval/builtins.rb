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
    Piret::Cons[*elements.map {|f| Piret.eval context, f}]
  end

  def fn(context, argv, *body)
    context = Piret::Eval::Context.new context

    if argv[-2] == :&
      rest = argv[-1]
      argv = argv[0...-2]
    elsif argv[-4] == :& and argv[-2] == :|
      rest = argv[-3]
      argv = argv[0...-4] + argv[-2..-1]
    else
      rest = nil
    end

    if argv[-2] == :|
      block = argv[-1]
      argv = argv[0...-2]
    else
      block = nil
    end

    lambda {|*args, &blockgiven|
      if !rest ? (args.length != argv.length) : (args.length < argv.length)
        raise ArgumentError,
            "wrong number of arguments (#{args.length} for #{argv.length})"
      end

      (0...argv.length).each do |i|
        context.set_here argv[i], args[i]
      end

      if rest
        context.set_here rest, Piret::Cons[*args[argv.length..-1]]
      end

      if block
        context.set_here block, blockgiven
      end

      Piret.eval context, *body
    }
  end

  def def(context, name, form)
    context.ns.set_here name, Piret.eval(context, form)
    :"#{context.ns.name}/#{name}"
  end

  def if(context, test, if_true, if_false=nil)
    # Note that we rely on Ruby's sense of truthiness. (only false and nil are
    # falsey)
    if Piret.eval(context, test)
      Piret.eval context, if_true
    else
      Piret.eval context, if_false
    end
  end
end

# vim: set sw=2 et cc=80:
