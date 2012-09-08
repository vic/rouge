# encoding: utf-8

class Atom
  def initialize(sym)
    @sym = sym
  end

  def ==(atom)
    atom.is_a?(Atom) and atom.sym == @sym
  end

  attr_reader :sym
end

class Symbol
  def atom
    Atom.new self
  end
end

# vim: set sw=2 et cc=80:
