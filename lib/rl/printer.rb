# encoding: utf-8
require 'rl/core'

module RL::Printer
  class UnknownFormError < StandardError; end

  def self.print(form)
    case form
    when Integer
      form.to_s
    when Symbol
      form.to_s
    when RL::Keyword
      form.symbol.inspect
    when String
      form.inspect
    when Array
      if form.length == 2 and form[0] == :quote
        "'#{print form[1]}"
      else
        "(#{form.map {|e| print e}.join " "})"
      end
    when Hash
      "{#{form.map {|k,v| print(k) + " " + print(v)}.join ", "}}"
    else
      raise UnknownFormError, "unknown form: #{form.inspect}"
    end
  end
end

# vim: set sw=2 et cc=80:
