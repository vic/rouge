# encoding: utf-8
require 'spec_helper'
require 'piret'

describe [Piret::Keyword, Piret::Macro, Piret::Builtin] do
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
end

describe Piret::Cons do
  describe "the multi-constructor" do
    it "should create a Cons for each element" do
      Piret::Cons[].should eq Piret::Cons::Empty
      Piret::Cons[1].should eq Piret::Cons.new(1, Piret::Cons::Empty)
      Piret::Cons[1, 2].
          should eq Piret::Cons.new(1, Piret::Cons.new(2, Piret::Cons::Empty))
      Piret::Cons[1, 2, 3].
          should eq Piret::Cons.new(1,
                    Piret::Cons.new(2,
                    Piret::Cons.new(3, Piret::Cons::Empty)))
    end
  end

  describe "the Ruby pretty-printing" do
    it "should resemble the constructor" do
      Piret::Cons[].inspect.should eq "Piret::Cons[]"
      Piret::Cons[1].inspect.should eq "Piret::Cons[1]"
      Piret::Cons[1, 2].inspect.should eq "Piret::Cons[1, 2]"
      Piret::Cons[1, 2, 3].inspect.should eq "Piret::Cons[1, 2, 3]"
      Piret::Cons[1, 2, 3].tail.inspect.should eq "Piret::Cons[2, 3]"
    end
  end

  describe "the index-access getter" do
    it "should get single elements" do
      Piret::Cons[1, 2, 3][0].should eq 1
      Piret::Cons[1, 2, 3][1].should eq 2
    end

    it "should return nil if an element is not present" do
      Piret::Cons[1, 2, 3][5].should eq nil
    end

    it "should work with negative indices" do
      Piret::Cons[1, 2, 3][-1].should eq 3
      Piret::Cons[1, 2, 3][-2].should eq 2
    end

    it "should return Arrays for ranges" do
      Piret::Cons[1, 2, 3][0..-1].should eq [1, 2, 3]
      Piret::Cons[1, 2, 3][0..-2].should eq [1, 2]
      Piret::Cons[1, 2, 3][0...-2].should eq [1]
      Piret::Cons[1, 2, 3][2...-1].should eq []
      Piret::Cons[1, 2, 3][2..-1].should eq [3]
    end
  end
end

# vim: set sw=2 et cc=80:
