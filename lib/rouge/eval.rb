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

      return r if forms.length.zero?
    end
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
      backtrace_fix "(rouge):?:builtin: " + Rouge.print(form) do
        fun.inner.call context, *form.to_a[1..-1]
      end
    when Rouge::Macro
      macro_form = backtrace_fix "(rouge):?:macro expand: " + Rouge.print(form) do 
        fun.inner.call(*form.to_a[1..-1])
      end
      backtrace_fix "(rouge):?:macro run: " + Rouge.print(macro_form) do
        eval context, macro_form
      end
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

      backtrace_fix "(rouge):?:lambda: " + Rouge.print(form) do
        fun.call *args, &block
      end
    end
  end

  private

  def backtrace_fix name, &block
    begin
      block.call
    rescue Exception => e
      STDOUT.puts block.source_location.join(':')
      target = block.source_location.join(':')
      changed = 0
      $!.backtrace.map! {|line|
        if line.scan("#{target}:").size > 0 and changed == 0
          changed += 1
          name
        else
          line
        end
      }
      raise e
    end
  end
end

# vim: set sw=2 et cc=80:
