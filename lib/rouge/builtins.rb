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
      context.set_here k.inner, context.eval(v)
    end
    context.eval(*body)
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
        begin
          raise ArgumentError,
              "wrong number of arguments (#{args.length} for #{argv.length})"
        rescue ArgumentError => e
          e.backtrace.pop
          e.backtrace.unshift "(rouge):?:lambda call"
          raise e
        end
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

      context.eval(*body)
    }
  end

  def def(context, name, *form)
    case form.length
    when 0
      context.ns.intern name.inner
    when 1
      context.ns.set_here name.inner, context.eval(form[0])
    else
      raise ArgumentError, "def called with too many forms #{form.inspect}"
    end
  end

  def if(context, test, if_true, if_false=nil)
    # Note that we rely on Ruby's sense of truthiness. (only false and nil are
    # falsey)
    if context.eval(test)
      context.eval if_true
    else
      context.eval if_false
    end
  end

  def do(context, *forms)
    context.eval *forms
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
        context.eval(Rouge::Cons[Rouge::Symbol[:fn], args, *body].freeze)]

    # XXX: should be a var. defmacro could be a non-builtin
    Rouge::Symbol[:"#{context.ns.name}/#{name.inner}"]
  end

  def apply(context, fun, *args)
    args =
        args[0..-2].map {|f| context.eval f} +
        context.eval(args[-1]).to_a
    # This is a terrible hack.
    context.eval(Rouge::Cons[
        fun,
        *args.map {|a| Rouge::Cons[Rouge::Symbol[:quote], a].freeze}.freeze])
  end

  def var(context, symbol)
    context.locate symbol.inner
  end

  def throw(context, throwable)
    exception = context.eval(throwable)
    begin
      raise exception
    rescue Exception => e
      # TODO
      e.backtrace.unshift "(rouge):?:throw"
      raise e
    end
  end
  
  def try(context, *body)
    return unless body.length > 0

    form = body[-1]
    if form.is_a?(Rouge::Cons) and form[0] == Rouge::Symbol[:finally]
      finally = form[1..-1]
      body.pop
    end

    catches = {}
    while body.length > 0
      form = body[-1]
      if !form.is_a?(Rouge::Cons) or form[0] != Rouge::Symbol[:catch]
        break
      end

      body.pop
      catches[context.eval(form[1])] =
        {:bind => form[2],
         :body => form[3..-1]}
    end

    r =
      begin
        context.eval *body
      rescue Exception => e
        catches.each do |klass, caught|
          if klass === e
            subcontext = Rouge::Context.new context
            subcontext.set_here caught[:bind].inner, e
            r = subcontext.eval(*caught[:body])
            context.eval(*finally) if finally
            return r
          end
        end
        context.eval(*finally) if finally
        raise e
      end

    context.eval(*finally) if finally
    r
  end
end

# vim: set sw=2 et cc=80:
