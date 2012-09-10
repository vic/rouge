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
          parts = form.to_s.split("/")

          if parts.length == 1
            sub = context
          elsif parts.length == 2
            sub = RL::Eval::Namespace[parts.shift.intern]
          else
            raise "parts.length not in 1, 2" # TODO
          end

          lookups = parts[0].split('.')
          sub = sub[lookups.shift.intern]

          while lookups.length > 0
            sub = sub.const_get(lookups.shift.intern)
          end

          sub
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
