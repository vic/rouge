# encoding: utf-8
require 'spec_helper'
require 'rl'

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

# vim: set sw=2 et cc=80:
