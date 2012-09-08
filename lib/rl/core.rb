# encoding: utf-8

class RL::Keyword
  def initialize(symbol)
    @symbol = symbol
  end

  def self.[](symbol)
    new symbol
  end

  def ==(keyword)
    keyword.is_a?(RL::Keyword) and keyword.symbol == @symbol
  end

  attr_reader :symbol
end

# vim: set sw=2 et cc=80:
