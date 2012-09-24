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

# vim: set sw=2 et cc=80:
