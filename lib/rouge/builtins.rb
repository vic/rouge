# encoding: utf-8

module Rouge::Builtins
  SYMBOLS = {
    :nil => nil,
    :true => true,
    :false => false,
  }
end

class << Rouge::Builtins
  def let(context, bindings, *body)
    context = Rouge::Context.new context
    bindings.each_slice(2) do |k, v|
      context.set_here k.inner, Rouge::Eval.eval(context, v)
    end
    Rouge.eval context, *body
  end

  def quote(context, form)
    form
  end

  def fn(context, argv, *body)
    context = Rouge::Context.new context

    if argv[-2] == Rouge::Symbol[:&]
      rest = argv[-1]
      argv = argv[0...-2]
    elsif argv[-4] == Rouge::Symbol[:&] and argv[-2] == Rouge::Symbol[:|]
      rest = argv[-3]
      argv = argv[0...-4] + argv[-2..-1]
    else
      rest = nil
    end

    if argv[-2] == Rouge::Symbol[:|]
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
        context.set_here argv[i].inner, args[i]
      end

      if rest
        context.set_here rest.inner, Rouge::Cons[*args[argv.length..-1]]
      end

      if block
        context.set_here block.inner, blockgiven
      end

      Rouge.eval context, *body
    }
  end

  def def(context, name, form)
    context.ns.set_here name.inner, Rouge.eval(context, form)
    Rouge::Symbol[:"#{context.ns.name}/#{name.inner}"]
  end

  def if(context, test, if_true, if_false=nil)
    # Note that we rely on Ruby's sense of truthiness. (only false and nil are
    # falsey)
    if Rouge.eval(context, test)
      Rouge.eval context, if_true
    else
      Rouge.eval context, if_false
    end
  end

  def do(context, *forms)
    Rouge.eval context, *forms
  end

  def ns(context, name, *args)
    ns = Rouge[name.inner]
    ns.refer Rouge[:"rouge.builtin"]

    args.each do |arg|
      if arg[0] == :use
        arg[1..-1].each do |use|
          ns.refer Rouge[use.inner]
        end
      else
        raise "TODO bad arg in ns: #{arg}"
      end
    end

    context = Rouge::Context.new ns
    raise Rouge::Eval::ChangeContextException, context
  end

  def defmacro(context, name, args, *body)
    context.ns.set_here name.inner, Rouge::Macro[
        Rouge.eval(context, Rouge::Cons[Rouge::Symbol[:fn], args, *body])]

    # XXX: should be a var. defmacro could be a non-builtin
    Rouge::Symbol[:"#{context.ns.name}/#{name.inner}"]
  end

  def apply(context, fun, *args)
    args =
        args[0..-2].map {|f| Rouge.eval context, f} +
        Rouge.eval(context, args[-1]).to_a
    # This is a terrible hack.
    Rouge.eval(context,
        Rouge::Cons[fun, *args.map {|a| Rouge::Cons[Rouge::Symbol[:quote], a]}])
  end
end

# vim: set sw=2 et cc=80:
