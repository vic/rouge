# encoding: utf-8

[:Keyword, :Macro, :Builtin].each do |name|
  RL.const_set name, Class.new {
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

class RL::Cons
  def new(head, tail)
    if tail != nil and !tail.is_a?(RL::Cons)
      raise ArgumentError, "RL::Cons tail should be RL::Cons or nil, not #{tail}"
    end

    @head, @tail = head, tail
  end

  def self.[](*elements)
    # TODO
    raise "TODO"
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
