# encoding: utf-8
require 'rl/core'

module RL::Eval
  require 'rl/eval/context'

  module Builtins
    def self.let(context, bindings, *body)
      context = RL::Eval::Context.new context
      bindings.each_slice(2) do |k, v|
        context.set_here k, RL::Eval.eval(v, context)
      end
    end
  end

  def self.eval(form, context)
    case form
    when Symbol
      context[form]
    when Array
      fun = eval form[0], context
      if fun.is_a? RL::Macro
        eval fun.call(context, *form[1..-1]), context
      else
        fun.call *form[1..-1].map {|f| eval f, context}
      end
    else
      form
    end
  end
end

# vim: set sw=2 et cc=80:
