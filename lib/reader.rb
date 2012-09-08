# encoding: utf-8
require 'core'

class Reader
  class UnexpectedCharacterError < StandardError; end
  class TrailingDataError < StandardError; end
  class EndOfDataError < StandardError; end

  def self.read(input)
    new(input).lex
  end

  def initialize(input)
    @src = input
    @n = 0
  end

  def lex
    r = 
      case peek
      when NUMBER
        number
      when SYMBOL
        symbol
      when KEYWORD_OPEN
        keyword
      when SPECIAL_OPEN
        special
      when STRING_OPEN
        string
      else
        raise UnexpectedCharacterError, "#{peek} in #lex"
      end

    unless @n == @src.length
      raise TrailingDataError, "remaining in #lex: #{@src[@n..-1]}"
    end

    r
  end

  private

  def number
    slurp(NUMBER).gsub(/\D+/, '').to_i
  end

  def symbol
    slurp(SYMBOL).intern
  end

  def keyword
    begin
      slurp(KEYWORD_STRING_OPEN)
      @n -= 1
      s = string
      s.intern.to_keyword
    rescue UnexpectedCharacterError
      slurp(KEYWORD)[1..-1].intern.to_keyword
    end
  end

  def special
    consume
    case c = consume
    when ?t
      true
    when ?f
      false
    when ?n
      nil
    when nil
      raise EndOfDataError, "in #special"
    else
      raise UnexpectedCharacterError, "#{c} in special"
    end
  end

  def string
    s = ""
    t = consume
    while true
      c = consume

      if c.nil?
        raise EndOfDataError, "in string, got: #{s}"
      end

      if c == t
        break
      end

      if c == ?\\
        c = consume

        case c
        when nil
          raise EndOfDataError, "in escaped string, got: #{s}"
        when /[abefnrstv]/
          c = {?a => ?\a,
               ?b => ?\b,
               ?e => ?\e,
               ?f => ?\f,
               ?n => ?\n,
               ?r => ?\r,
               ?s => ?\s,
               ?t => ?\t,
               ?v => ?\v}[c]
        else
          # Just leave it be.
        end
      end

      s += c
    end
    s
  end

  def slurp re
    @src[@n..-1] =~ re
    raise UnexpectedCharacterError, "#{@src[@n]} in #slurp #{re}" if !$&
    @n += $&.length
    $&
  end

  def peek
    @src[@n]
  end

  def consume
    c = peek
    @n += 1
    c
  end

  NUMBER = /^[0-9][0-9_]*/
  SYMBOL = /^[a-zA-Z0-9\-_!\?\*\/]+/
  KEYWORD_OPEN = /^:/
  KEYWORD = /^:[a-zA-Z0-9\-_!\?\*\/]+/
  KEYWORD_STRING_OPEN = /^:["']/
  SPECIAL_OPEN = /^#/
  STRING_OPEN = /^['"]/
end

# vim: set sw=2 et cc=80: