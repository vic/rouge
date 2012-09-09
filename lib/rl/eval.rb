# encoding: utf-8
require 'rl/core'

module RL::Eval
  require 'rl/eval/context'

  def self.eval(form, context)
    case form
    when Symbol
      context[form]
    when Array
      if form.length == 2 and form[0] == :quote
        form[1]
      else
        eval(form[0], context).call *form[1..-1].map {|f| eval(f, context)}
      end
    else
      form
    end
  end
end

# vim: set sw=2 et cc=80:
