# encoding: utf-8

# TODO: refactor and possibly move.

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

class RL::Macro
  def initialize(lamda)
    @lamda = lamda
  end

  def self.[](lamda)
    new lamda
  end

  def ==(macro)
    macro.is_a?(RL::Macro) and macro.lamda == @lamda
  end

  attr_reader :lamda
end

# vim: set sw=2 et cc=80:
