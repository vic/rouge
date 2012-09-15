# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Atom do
  describe "the constructor" do
    it "creates an atom with an initial value" do
      v = Rouge::Atom.new(:snorlax)
      v.deref.should eq :snorlax
    end
  end

  describe "equality" do
    it "only considers two atoms equal if they're identical" do
      a = Rouge::Atom.new(:raichu)
      b = Rouge::Atom.new(:raichu)
      a.should_not == b
    end
  end

  describe "the swap! method" do
    it "should apply the function (and any arguments) to the atom's value" do
      v = Rouge::Atom.new(456)
      v.swap!(lambda {|n| n * 2})
      v.deref.should eq 912

      v.swap!(lambda {|n, m| [n / 2, m]}, "quack")
      v.deref.should eq [456, "quack"]
    end
  end
end

# vim: set sw=2 et cc=80:
