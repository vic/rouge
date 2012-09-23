# encoding: utf-8
require 'rouge/metadata'

[:Symbol, :Macro, :Builtin, :Dequote, :Splice].each do |name|
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
  include Rouge::Metadata

  # The symbols for t/f/n are the Ruby objects themselves.
  @lookup = {
    :true => true,
    :false => false,
    :nil => nil,
  }

  def self.[](inner)
    return @lookup[inner] if @lookup.include? inner
    # Note: don't cache symbols themselves, they may have metadata.
    new inner
  end

  def ns
    return nil if inner == :/
    return :"rouge.core" if inner == :"rouge.core//"
    rparts = inner.to_s.reverse.split('/', 2)
    return nil if rparts.length < 2
    rparts[1].reverse.intern
  end

  def name
    return :/ if inner == :/
    return :/ if inner == :"rouge.core//"
    rparts = inner.to_s.reverse.split('/', 2)
    rparts[0].reverse.intern
  end
end

class Rouge::Cons
  def initialize(head, tail)
    if tail != Empty and !tail.is_a?(Rouge::Cons)
      raise ArgumentError,
        "tail should be a Rouge::Cons or Empty, not #{tail}"
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
      head = new(elements[i], head).freeze
    end

    head
  end

  def each(&block)
    here = self

    while here and here != Rouge::Cons::Empty
      block.call here.head
      here = here.tail
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
Rouge::Cons::Empty.freeze

# vim: set sw=2 et cc=80:
