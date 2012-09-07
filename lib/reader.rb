# encoding: utf-8

class Reader
  class UnexpectedCharacterError < StandardError; end
  class TrailingDataError < StandardError; end

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

  def slurp re
    @src =~ re
    @n += $&.length
    $&
  end

  def peek
    @src[@n]
  end

  NUMBER = /^[0-9][0-9_]*/
  SYMBOL = /^[a-zA-Z0-9\-_!\?]+/
end

# vim: set sw=2 et cc=80:
