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
          parts = form.to_s.split("/").map(&:intern)

          my_context = context

          if parts.length > 1 and parts[0] == :r
            my_context = Kernel
            parts.shift
          end

          while parts.length > 0
            if my_context.is_a?(Hash) or my_context.is_a?(RL::Eval::Context)
              my_context = my_context[parts.shift]
            elsif parts[0].to_s[0].chr =~ /[A-Z]/
              my_context = my_context.const_get parts.shift
            end
          end

          my_context
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
