# encoding: utf-8
require 'spec_helper'
require 'core'

describe Atom do
  describe "the constructor" do
    it "should return a new atom" do
      Atom.new(:abc).should be_an_instance_of(Atom)
    end
  end

  describe "atom equality" do
    it "should be true for two atoms with the same underlying symbol" do
      Atom.new(:xyz).should eq Atom.new(:xyz)
    end
  end
end

describe Symbol do
  describe "the atom method" do
    it "should return an atom for the given symbol" do
      :abc.atom.should eq Atom.new(:abc)
    end
  end
end

# vim: set sw=2 et cc=80:
