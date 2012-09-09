# encoding: utf-8
require 'rl/core'

module RL::Eval
  require 'rl/eval/context'

  class UnknownFormError < StandardError; end

  def self.eval(form)
    case form
    when Integer
      form
    when String
      form
    when RL::Keyword
      form
    when Symbol
      raise "TODO: symbol"
    when Array
      if form.length == 2 and form[0] == :quote
        form[1]
      else
        raise "TODO: funcall" # TODO
      end
    when Hash
      form
    else
      raise UnknownFormError, "unknown form: #{form.inspect}"
    end
  end
end

# vim: set sw=2 et cc=80:
