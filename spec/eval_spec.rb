# encoding: utf-8
require 'spec_helper'
require 'eval'

describe Eval do
  describe "the eval method" do
    it "should evaluate numbers to numbers" do
      Eval.eval(4).should eq 4
      Eval.eval(0).should eq 0
    end

    it "should evaluate strings to strings" do
      Eval.eval("bleep bloop").should eq "bleep bloop"
      Eval.eval("what \n\"barley").should eq "what \n\"barley"
    end

    it "should evaluate keywords to keywords" do
      Eval.eval(Keyword[:hihi]).should eq Keyword[:hihi]
      Eval.eval(Keyword[:"nom it"]).should eq Keyword[:"nom it"]
    end

    it "should evaluate symbols to the object within their context" do
      Eval.eval(:wut).should eq "TODO"
    end

    it "should evaluate quotations to their unquoted form" do
      Eval.eval([:quote, :x]).should eq :x
      Eval.eval([:quote, [:quote, Keyword[:zzy]]]).should eq \
        [:quote, Keyword[:zzy]]
    end

    it "should evaluate function calls" do
      raise "TODO"
    end
  end
end

# vim: set sw=2 et cc=80:
