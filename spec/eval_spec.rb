# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval do
  before do
    @context = RL::Eval::Context.new nil
  end

  describe "the eval method" do
    it "should evaluate numbers to themselves" do
      RL.eval(4, @context).should eq 4
      RL.eval(0, @context).should eq 0
    end

    it "should evaluate strings to themselves" do
      RL.eval("bleep bloop", @context).should eq "bleep bloop"
      RL.eval("what \n\"barley", @context).should eq "what \n\"barley"
    end

    it "should evaluate keywords to themselves" do
      RL.eval(RL::Keyword[:hihi], @context).should eq RL::Keyword[:hihi]
      RL.eval(RL::Keyword[:"nom it"], @context).should eq \
          RL::Keyword[:"nom it"]
    end

    it "should evaluate hashes to themselves" do
      RL.eval({"z" => 92, :x => [:quote, 5]}, @context).should eq(
          {"z" => 92, :x => [:quote, 5]})
      RL.eval({{{9 => 8} => 7} => 6}, @context).should eq(
          {{{9 => 8} => 7} => 6})
    end

    it "should evaluate quotations to their unquoted form" do
      RL.eval([:quote, :x], @context).should eq :x
      RL.eval([:quote, [:quote, RL::Keyword[:zzy]]], @context).should eq \
          [:quote, RL::Keyword[:zzy]]
    end

    it "should evaluate symbols to the object within their context" do
      @context.set_here :vitamin_b, "vegemite"
      RL.eval(:vitamin_b, @context).should eq "vegemite"

      subcontext = RL::Eval::Context.new @context
      subcontext.set_here :joy, [:yes]
      RL.eval(:joy, subcontext).should eq [:yes]
    end

    it "should evaluate function calls" do
      raise "TODO"
    end

    describe "unknown form behaviour" do
      it "should raise an exception with an unknown form" do
        lambda {
          RL.eval(lambda {}, @context)
        }.should raise_exception(RL::Eval::UnknownFormError)
      end
    end
  end
end

# vim: set sw=2 et cc=80:
