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
  Empty = Object.new

  def new(head, tail)
    if tail != Empty and !tail.is_a?(Piret::Cons)
      raise ArgumentError,
        "tail should be a Piret::Cons or Tail, not #{tail}"
    end

    @head, @tail = head, tail
  end

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

  include Enumerable
end

# vim: set sw=2 et cc=80:
