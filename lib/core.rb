# encoding: utf-8

class Keyword
  def initialize(symbol)
    @symbol = symbol
  end

  def self.[](symbol)
    new symbol
  end

  def ==(keyword)
    keyword.is_a?(Keyword) and keyword.symbol == @symbol
  end

  attr_reader :symbol
end

class Symbol
  def to_keyword
    Keyword.new self
  end
end

# vim: set sw=2 et cc=80:
