# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe [
    Rouge::Symbol,
    Rouge::Macro,
    Rouge::Builtin,
    Rouge::Dequote,
    Rouge::Splice] do
  describe "the constructor" do
    it "should return a new wrapper" do
      described_class.each do |klass|
        klass.new(:abc).should be_an_instance_of klass
      end
    end

    it "should function with the alternate form" do
      described_class.each do |klass|
        klass[:aoeu].should eq klass.new(:aoeu)
      end
    end
  end

  describe "equality" do
    it "should be true for two wrappers with the same underlying object" do
      described_class.each do |klass|
        klass.new(:xyz).should eq klass.new(:xyz)
      end
    end
  end

  describe "the inner getter" do
    it "should return the object passed in" do
      described_class.each do |klass|
        klass.new(:boohoo).inner.should eq :boohoo
        l = lambda {}
        klass.new(l).inner.should eq l
      end
    end
  end

  describe "the Puby pretty-printing" do
    it "should resemble the [] constructor" do
      described_class.each do |klass|
        klass[:hello].inspect.should eq "#{klass.name}[:hello]"
      end
    end
  end
end

describe Rouge::Symbol do
  describe "the lookup" do
    it "should return true, false and nil" do
      Rouge::Symbol[:true].should be true
      Rouge::Symbol[:false].should be false
      Rouge::Symbol[:nil].should be nil
    end
  end

  describe "the constructor" do
    it "should return new objects every time" do
      Rouge::Symbol[:a].should_not be Rouge::Symbol[:a]
      # but:
      Rouge::Symbol[:a].should eq Rouge::Symbol[:a]
    end
  end

  describe "the name and ns methods" do
    it "should return the parts of the symbol" do
      Rouge::Symbol[:abc].ns.should be_nil
      Rouge::Symbol[:abc].name.should eq :abc
      Rouge::Symbol[:"abc/def"].ns.should eq :abc
      Rouge::Symbol[:"abc/def"].name.should eq :def
      Rouge::Symbol[:/].ns.should be_nil
      Rouge::Symbol[:/].name.should eq :/
      Rouge::Symbol[:"rouge.core//"].ns.should eq :"rouge.core"
      Rouge::Symbol[:"rouge.core//"].name.should eq :/
    end
  end
end

# vim: set sw=2 et cc=80:
