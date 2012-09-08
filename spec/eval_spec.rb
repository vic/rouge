# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval do
  describe "the eval method" do
    it "should evaluate numbers to numbers" do
      RL.eval(4).should eq 4
      RL.eval(0).should eq 0
    end

    it "should evaluate strings to strings" do
      RL.eval("bleep bloop").should eq "bleep bloop"
      RL.eval("what \n\"barley").should eq "what \n\"barley"
    end

    it "should evaluate keywords to keywords" do
      RL.eval(RL::Keyword[:hihi]).should eq RL::Keyword[:hihi]
      RL.eval(RL::Keyword[:"nom it"]).should eq RL::Keyword[:"nom it"]
    end

    it "should evaluate symbols to the object within their context" do
      RL.eval(:wut).should eq "TODO"
    end

    it "should evaluate quotations to their unquoted form" do
      RL.eval([:quote, :x]).should eq :x
      RL.eval([:quote, [:quote, RL::Keyword[:zzy]]]).should eq \
          [:quote, RL::Keyword[:zzy]]
    end

    it "should evaluate function calls" do
      raise "TODO"
    end
  end
end

# vim: set sw=2 et cc=80:
