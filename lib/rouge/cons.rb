# encoding: utf-8

class Rouge::Cons
  def initialize(head, tail)
    if tail != Empty and !tail.is_a?(Rouge::Cons)
      raise ArgumentError,
        "tail should be a Rouge::Cons or Empty, not #{tail}"
    end

    @head, @tail = head, tail

    # Performance hack; every cons caches its own array?! XXX
    @to_a = [@head]
    cursor = @tail
    while cursor and cursor != Empty
      @to_a << cursor.head
      cursor = cursor.tail
    end
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
    @to_a.each(&block)
  end

  def ==(cons)
    cons.is_a?(Rouge::Cons) and @to_a == cons.to_a
  end

  def length
    @to_a.length
  end

  def [](i)
    @to_a[i]
  end

  attr_reader :head, :tail

  include Enumerable
end

Rouge::Cons::Empty = Object.new
class << Rouge::Cons::Empty
  def each(&block)
    return self.enum_for(:each) if block.nil?
  end
  def length; 0; end
  def [](i); nil; end
  def to_a; []; end
  def inspect; "Rouge::Cons[]"; end
  def to_s; inspect; end

  include Enumerable
end
Rouge::Cons::Empty.freeze

# vim: set sw=2 et cc=80:
