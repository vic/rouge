# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval do
  before do
    @context = RL::Eval::Context.new RL::Eval::Namespace[:rl]
  end

  describe "the eval method" do
    it "should evaluate quotations to their unquoted form" do
      RL.eval(@context, [:quote, :x]).should eq :x
      RL.eval(@context, [:quote, [:quote, RL::Keyword[:zzy]]]).should eq \
          [:quote, RL::Keyword[:zzy]]
    end

    describe "symbols" do
      it "should evaluate symbols to the object within their context" do
        @context.set_here :vitamin_b, "vegemite"
        RL.eval(@context, :vitamin_b).should eq "vegemite"

        subcontext = RL::Eval::Context.new @context
        subcontext.set_here :joy, [:yes]
        RL.eval(subcontext, :joy).should eq [:yes]
      end

      it "should evaluate symbols in the R namespace to Ruby objects" do
        RL.eval(@context, :"r/Object").should eq Object
        RL.eval(@context, :"r/RL/Eval/Context").should eq RL::Eval::Context
      end
    end

    it "should evaluate function calls" do
      RL.eval(@context, [lambda {|x| "hello #{x}"}, "world"]).should eq \
        "hello world"
    end

    it "should evaluate macro calls" do
      macro = RL::Macro[lambda {|n, body|
        [:let, [n, "example"],
          *body]
      }]

      RL.eval(@context, [macro, :bar, [[lambda {|x,y| x + y}, :bar, :bar]]]).
        should eq "exampleexample"
    end

    it "should evaluate other things to themselves" do
      RL.eval(@context, 4).should eq 4
      RL.eval(@context, "bleep bloop").should eq "bleep bloop"
      RL.eval(@context, RL::Keyword[:"nom it"]).should eq \
          RL::Keyword[:"nom it"]
      RL.eval(@context, {"z" => 92, :x => [:quote, 5]}).should eq(
          {"z" => 92, :x => [:quote, 5]})

      l = lambda {}
      RL.eval(@context, l).should eq l

      o = Object.new
      RL.eval(@context, o).should eq o
    end
  end

  describe "the traverse method" do
    it "should traverse RL::Eval::Namespaces" do
      RL::Eval.traverse(RL::Eval::Namespace[:rl], :let).
          should be_an_instance_of RL::Builtin
    end

    it "should traverse RL::Eval::Contexts" do
      @context.set_here :abc, :Zzz
      RL::Eval.traverse(@context, :abc).should eq :Zzz
    end

    it "should traverse Classes" do
      RL::Eval.traverse(RL::Reader, :EndOfDataError).should eq \
          RL::Reader::EndOfDataError
    end

    it "should traverse Modules" do
      RL::Eval.traverse(RL::Printer, :UnknownFormError).should eq \
          RL::Printer::UnknownFormError
    end
  end
end

# vim: set sw=2 et cc=80:
