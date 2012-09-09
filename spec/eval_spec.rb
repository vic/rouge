# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval do
  before do
    @context = RL::Eval::Context.new nil
  end

  describe "the eval method" do
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
      RL.eval([lambda {|x| "hello #{x}"}, "world"], @context).should eq \
        "hello world"
    end

    describe "built-ins" do
      it "should evaluate LET" do
        RL.eval([:let, [:a, 42], :a], @context).should eq 42
      end

      it "should evaluate QUOTE" do
        RL.eval([:quote, :lmnop], @context).should eq :lmnop
      end
    end

    it "should evaluate macro calls" do
      macro = RL::Macro[lambda {|n, body|
        [:let, [n, "example"],
          *body]
      }]

      RL.eval([macro, :bar, [[lambda {|x,y| x + y}, :bar, :bar]]], @context).
        should eq "exampleexample"
    end

    it "should evaluate other things to themselves" do
      RL.eval(4, @context).should eq 4
      RL.eval("bleep bloop", @context).should eq "bleep bloop"
      RL.eval(RL::Keyword[:"nom it"], @context).should eq \
          RL::Keyword[:"nom it"]
      RL.eval({"z" => 92, :x => [:quote, 5]}, @context).should eq(
          {"z" => 92, :x => [:quote, 5]})

      l = lambda {}
      RL.eval(l, @context).should eq l

      o = Object.new
      RL.eval(o, @context).should eq o
    end
  end
end

# vim: set sw=2 et cc=80:
