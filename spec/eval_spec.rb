# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Eval do
  before do
    @context = Piret::Eval::Context.new Piret::Eval::Namespace[:piret]
  end

  it "should evaluate quotations to their unquoted form" do
    Piret.eval(@context, [:quote, :x]).should eq :x
    Piret.eval(@context, [:quote, [:quote, Piret::Keyword[:zzy]]]).should eq \
        [:quote, Piret::Keyword[:zzy]]
  end

  describe "symbols" do
    it "should evaluate symbols to the object within their context" do
      @context.set_here :vitamin_b, "vegemite"
      Piret.eval(@context, :vitamin_b).should eq "vegemite"

      subcontext = Piret::Eval::Context.new @context
      subcontext.set_here :joy, [:yes]
      Piret.eval(subcontext, :joy).should eq [:yes]
    end

    it "should evaluate symbols in other namespaces" do
      Piret.eval(@context, :"ruby/Object").should eq Object
      Piret.eval(@context, :"ruby/Exception").should eq Exception
    end

    it "should evaluate nested objects (in local and foreign namespaces)" do
      Piret.eval(@context, :"ruby/Piret.Eval.Context").should eq \
          Piret::Eval::Context
      Piret.eval(@context, :"Errno.EAGAIN").should eq Errno::EAGAIN
    end
  end

  it "should evaluate function calls" do
    Piret.eval(@context, [lambda {|x| "hello #{x}"}, "world"]).should eq \
      "hello world"
  end

  it "should evaluate macro calls" do
    macro = Piret::Macro[lambda {|n, body|
      [:let, [n, "example"],
        *body]
    }]

    Piret.eval(@context, [macro, :bar, [[lambda {|x,y| x + y}, :bar, :bar]]]).
      should eq "exampleexample"
  end

  it "should evaluate other things to themselves" do
    Piret.eval(@context, 4).should eq 4
    Piret.eval(@context, "bleep bloop").should eq "bleep bloop"
    Piret.eval(@context, Piret::Keyword[:"nom it"]).should eq \
        Piret::Keyword[:"nom it"]
    Piret.eval(@context, {"z" => 92, :x => [:quote, 5]}).should eq(
        {"z" => 92, :x => [:quote, 5]})

    l = lambda {}
    Piret.eval(@context, l).should eq l

    o = Object.new
    Piret.eval(@context, o).should eq o
  end

  describe "Ruby interop" do
    describe "new object creation" do
      it "should call X.new with (X.)" do
        klass = double("klass")
        klass.should_receive(:new).with(:a).and_return(:b)

        subcontext = Piret::Eval::Context.new @context
        subcontext.set_here :klass, klass
        Piret.eval(subcontext, [:"klass.", [:quote, :a]]).should eq :b
      end
    end

    describe "generic method calls" do
      it "should call x.y(z) with (.y x)" do
        x = double("x")
        x.should_receive(:y).with(:z).and_return(:tada)

        subcontext = Piret::Eval::Context.new @context
        subcontext.set_here :x, x
        Piret.eval(subcontext, [:".y", :x, [:quote, :z]]).should eq :tada
      end
    end
  end
end

# vim: set sw=2 et cc=80:
