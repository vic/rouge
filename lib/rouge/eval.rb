# encoding: utf-8
module Rouge::Eval
  require 'rouge/wrappers'
  require 'rouge/context'
  require 'rouge/namespace'

  class BindingNotFoundError < StandardError; end
  class ChangeContextException < Exception
    def initialize(context); @context = context; end
    attr_reader :context
  end
end

class << Rouge::Eval
  def eval(context, *forms)
    return nil if forms.length.zero?

    while true
      form = forms.shift
      r =
        begin
          case form
          when Rouge::Symbol
            eval_symbol context, form
          when Rouge::Cons
            begin
              eval_cons context, form
            rescue Rouge::Eval::ChangeContextException => cce
              context = cce.context
            end
          when Hash
            Hash[*
                form.map {|k,v| [eval(context, k), eval(context, v)]}.flatten(1)]
          when Array
            form.map {|f| eval context, f}
          else
            form
          end
        rescue Exception => e
          if form.is_a?(Rouge::Cons)
            # BACKWARDS w/in context of rouge errors themselves.
            e.backtrace.unshift "(rouge):?:#{Rouge.print(form)[0...30]}"
          end
          raise e
        end

      return r if forms.length.zero?
    end
  rescue Exception => e
    # Remove Rouge-related lines unless the exception originated in Rouge.
    e.backtrace.collect! {|line|
      line.scan(File.dirname(__FILE__)).length > 0 ? nil : line
    }.compact! unless e.backtrace[0].scan(File.dirname(__FILE__)).length > 0
    raise e
  end

  private

  def eval_symbol(context, form)
    form = form.inner.to_s
    if form[0] == ?.
      form = form[1..-1]
      lambda {|receiver, *args, &block|
        receiver.send(form, *args, &block)
      }
    else
      result = context.locate form
      if result.is_a?(Rouge::Var)
        result.deref
      else
        result
      end
    end
  end

  def eval_cons(context, form)
    fun = eval context, form[0]
    case fun
    when Rouge::Builtin
      fun.inner.call context, *form.to_a[1..-1]
    when Rouge::Macro
      eval context, fun.inner.call(*form.to_a[1..-1])
    else
      args = form.to_a[1..-1]

      if args.include? Rouge::Symbol[:|]
        index = args.index Rouge::Symbol[:|]
        if args.length == index + 2
          # Function.
          block = eval context, args[index + 1]
        else
          # Inline block.
          block = eval context,
              Rouge::Cons[Rouge::Symbol[:fn],
                          args[index + 1],
                          *args[index + 2..-1]]
        end
        args = args[0...index]
      else
        block = nil
      end

      args = args.map {|f| eval context, f}

      fun.call *args, &block
    end
  end
end

# vim: set sw=2 et cc=80:
