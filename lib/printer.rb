# encoding: utf-8
require 'core'

module Printer; end

class << Printer
  def print(input)
    case input
    when Integer
      input.to_s
    when Symbol
      input.to_s
    when Keyword
      input.symbol.inspect
    when String
      input.inspect
    when Array
      if input.length == 2 and input[0] == :quote
        "'#{print input[1]}"
      else
        "(#{input.map {|e| print e}.join " "})"
      end
    when Hash
      "{#{input.map {|k,v| print(k) + " " + print(v)}.join ", "}}"
    end
  end
end

# vim: set sw=2 et cc=80:
