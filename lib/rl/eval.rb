# encoding: utf-8
require 'rl/core'

module RL::Eval
  require 'rl/eval/context'

  def self.eval(context, *forms)
    return nil if forms.length.zero?

    while true
      form = forms.shift
      r =
        case form
        when Symbol
          context[form]
        when Array
          fun = eval context, form[0]
          case fun
          when RL::Builtin
            fun.inner.call context, *form[1..-1]
          when RL::Macro
            eval context, fun.call(context, *form[1..-1])
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
