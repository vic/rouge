# encoding: utf-8

# TODO: possibly move.
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

# vim: set sw=2 et cc=80:
