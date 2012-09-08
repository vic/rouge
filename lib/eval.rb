# encoding: utf-8
require 'core'

module Eval; end

class << Eval
  def eval(form)
    case form
    when Integer
      form
    when String
      form
    when Keyword
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
