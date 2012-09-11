# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe [Rouge::Symbol, Rouge::Macro, Rouge::Builtin] do
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
  describe "the cache" do
    it "should return the same Rouge::Symbol for the same inner symbol" do
      Rouge::Symbol[:x].should be Rouge::Symbol[:x]
    end
  end
end

describe Rouge::Cons do
  describe "the multi-constructor" do
    it "should create a Cons for each element" do
      Rouge::Cons[].should eq Rouge::Cons::Empty
      Rouge::Cons[1].should eq Rouge::Cons.new(1, Rouge::Cons::Empty)
      Rouge::Cons[1, 2].
          should eq Rouge::Cons.new(1, Rouge::Cons.new(2, Rouge::Cons::Empty))
      Rouge::Cons[1, 2, 3].
          should eq Rouge::Cons.new(1,
                    Rouge::Cons.new(2,
                    Rouge::Cons.new(3, Rouge::Cons::Empty)))
    end
  end

  describe "the Ruby pretty-printing" do
    it "should resemble the constructor" do
      Rouge::Cons[].inspect.should eq "Rouge::Cons[]"
      Rouge::Cons[1].inspect.should eq "Rouge::Cons[1]"
      Rouge::Cons[1, 2].inspect.should eq "Rouge::Cons[1, 2]"
      Rouge::Cons[1, 2, 3].inspect.should eq "Rouge::Cons[1, 2, 3]"
      Rouge::Cons[1, 2, 3].tail.inspect.should eq "Rouge::Cons[2, 3]"
    end
  end

  describe "the index-access getter" do
    it "should get single elements" do
      Rouge::Cons[1, 2, 3][0].should eq 1
      Rouge::Cons[1, 2, 3][1].should eq 2
    end

    it "should return nil if an element is not present" do
      Rouge::Cons[1, 2, 3][5].should eq nil
    end

    it "should work with negative indices" do
      Rouge::Cons[1, 2, 3][-1].should eq 3
      Rouge::Cons[1, 2, 3][-2].should eq 2
    end

    it "should return Arrays for ranges" do
      Rouge::Cons[1, 2, 3][0..-1].should eq [1, 2, 3]
      Rouge::Cons[1, 2, 3][0..-2].should eq [1, 2]
      Rouge::Cons[1, 2, 3][0...-2].should eq [1]
      Rouge::Cons[1, 2, 3][2...-1].should eq []
      Rouge::Cons[1, 2, 3][2..-1].should eq [3]
    end
  end
end

# vim: set sw=2 et cc=80:
