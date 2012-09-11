# encoding: utf-8

[:Symbol, :Macro, :Builtin].each do |name|
  Rouge.const_set name, Class.new {
    def initialize(inner)
      @inner = inner
    end

    def self.[](inner)
      new inner
    end

    def inspect
      "#{self.class.name}[#{@inner.inspect}]"
    end

    def to_s; inspect; end

    def ==(right)
      right.is_a?(self.class) and right.inner == @inner
    end

    attr_reader :inner
  }
end

class Rouge::Symbol
  @@cache = {}

  def self.[](inner)
    sym = Rouge::Symbol.class_variable_get('@@cache')[inner]
    return sym if sym

    Rouge::Symbol.class_variable_get('@@cache')[inner] = new inner
  end
end

class Rouge::Cons
  def initialize(head, tail)
    if tail != Empty and !tail.is_a?(Rouge::Cons)
      raise ArgumentError,
        "tail should be a Rouge::Cons or Tail, not #{tail}"
    end

    @head, @tail = head, tail
  end

  def inspect
    "Rouge::Cons[#{to_a.map(&:inspect).join ", "}]"
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
    cons.is_a?(Rouge::Cons) and to_a == cons.to_a
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

Rouge::Cons::Empty = Object.new
class << Rouge::Cons::Empty
  def each(&block); end
  def length; 0; end
  def [](i); nil; end
  def to_a; []; end
  def inspect; "Rouge::Cons[]"; end
  def to_s; inspect; end

  include Enumerable
end

# vim: set sw=2 et cc=80:
