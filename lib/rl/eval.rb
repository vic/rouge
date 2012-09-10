# encoding: utf-8
require 'rl/core'

module RL::Eval
  require 'rl/eval/context'
  require 'rl/eval/namespace'
end

class << RL::Eval
  def eval(context, *forms)
    return nil if forms.length.zero?

    while true
      form = forms.shift
      r =
        case form
        when Symbol
          parts = form.to_s.split("/").map(&:intern)

          my_context = context

          if parts.length > 1
            my_context = RL::Eval::Namespace[parts.shift]
          end

          while parts.length > 0
            my_context = traverse my_context, parts.shift
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

  def traverse(ns, name)
    case ns
    when RL::Eval::Context, RL::Eval::Namespace
      ns = ns[name]
    when Class, Module
      ns = ns.const_get name
    end
  end
end

# vim: set sw=2 et cc=80:
