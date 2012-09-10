# encoding: utf-8

[:Keyword, :Macro, :Builtin].each do |name|
  Piret.const_set name, Class.new {
    def initialize(inner)
      @inner = inner
    end

    def self.[](inner)
      new inner
    end

    def ==(right)
      right.is_a?(self.class) and right.inner == @inner
    end

    attr_reader :inner
  }
end

class Piret::Cons
  def initialize(head, tail)
    if tail != Empty and !tail.is_a?(Piret::Cons)
      raise ArgumentError,
        "tail should be a Piret::Cons or Tail, not #{tail}"
    end

    @head, @tail = head, tail
  end

  def inspect
    "Piret::Cons[#{to_a.map(&:inspect).join ", "}]"
  end

  def to_s; inspect; end

  def self.[](*elements)
    head = Empty
    (elements.length - 1).downto(0).each do |i|
      head = new(elements[i], head)
    end

    head
  end

  def each(&block)
    block.call head
    if tail
      tail.each &block
    end
  end

  def ==(cons)
    cons.is_a?(Piret::Cons) and to_a == cons.to_a
  end

  def length
    to_a.length
  end

  def [](i)
    to_a[i]
  end

  attr_reader :head, :tail

  include Enumerable
end

Piret::Cons::Empty = Object.new
class << Piret::Cons::Empty
  def each(&block); end
  def length; 0; end
  def [](i); nil; end
  def to_a; []; end
  def inspect; "Piret::Cons[]"; end
  def to_s; inspect; end

  include Enumerable
end

# vim: set sw=2 et cc=80:
