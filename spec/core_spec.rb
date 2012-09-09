# encoding: utf-8
require 'spec_helper'
require 'rl'

# TODO: refactor and possibly move.

describe RL::Keyword do
  describe "the constructor" do
    it "should return a new keyword" do
      RL::Keyword.new(:abc).should be_an_instance_of RL::Keyword
    end

    it "should function with the alternate form" do
      RL::Keyword[:aoeu].should eq RL::Keyword.new(:aoeu)
    end
  end

  describe "keyword equality" do
    it "should be true for two keyword with the same underlying symbol" do
      RL::Keyword.new(:xyz).should eq RL::Keyword.new(:xyz)
    end
  end
end

describe RL::Macro do
  describe "the constructor" do
    it "should return a new keyword" do
      RL::Macro.new(lambda {}).should be_an_instance_of RL::Macro
    end

    it "should function with the alternate form" do
      l = lambda {}
      RL::Macro[l].should eq RL::Macro.new(l)
    end
  end

  describe "keyword equality" do
    it "should be true for two keyword with the same underlying symbol" do
      l = lambda {}
      RL::Macro.new(l).should eq RL::Macro.new(l)
    end
  end
end

# vim: set sw=2 et cc=80:
