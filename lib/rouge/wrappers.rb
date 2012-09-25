# encoding: utf-8

[:Macro, :Builtin, :Dequote, :Splice].each do |name|
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

# vim: set sw=2 et cc=80:
