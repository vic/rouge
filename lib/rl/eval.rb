# encoding: utf-8
require 'rl/core'

module RL::Eval; end

class << RL::Eval
  def eval(form)
    case form
    when Integer
      form
    when String
      form
    when RL::Keyword
      form
    when Symbol
      raise "TODO"
    when Array
      if form.length == 2 and form[0] == :quote
        form[1]
      else
        raise "TODO" # TODO
      end
    else
      raise "TODO" # TODO: error
    end
  end
end

# vim: set sw=2 et cc=80:
