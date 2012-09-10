# encoding: utf-8
require 'rl/core'

module RL::Eval
  require 'rl/eval/context'
  require 'rl/eval/namespace'

  class BindingNotFoundError < StandardError; end
end

class << RL::Eval
  def eval(context, *forms)
    return nil if forms.length.zero?

    while true
      form = forms.shift
      r =
        case form
        when Symbol
          form = form.to_s
          will_new = form[-1] == ?.
          form = form[0..-2] if will_new

          parts = form.split("/")

          if parts.length == 1
            sub = context
          elsif parts.length == 2
            sub = RL::Eval::Namespace[parts.shift.intern]
          else
            raise "parts.length not in 1, 2" # TODO
          end

          lookups = parts[0].split(/(?<=.)\.(?=.)/)
          sub = sub[lookups.shift.intern]

          while lookups.length > 0
            sub = sub.const_get(lookups.shift.intern)
          end

          if will_new
            sub.method(:new)
          else
            sub
          end
        when Array
          fun = eval context, form[0]
          case fun
          when RL::Builtin
            fun.inner.call context, *form[1..-1]
          when RL::Macro
            eval context, fun.inner.call(*form[1..-1])
          else
            fun.call *form[1..-1].map {|f| eval context, f}
          end
        else
          form
        end

      return r if forms.length.zero?
    end
  end
end

# vim: set sw=2 et cc=80:
