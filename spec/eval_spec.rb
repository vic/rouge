# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Eval do
  before do
    @context = Rouge::Context.new Rouge[:"rouge.builtin"]
  end

  it "should evaluate quotations to their unquoted form" do
    @context.readeval("'x").should eq Rouge.read("x")
    @context.readeval("'':zzy").should eq Rouge.read("':zzy")
  end

  describe "symbols" do
    it "should evaluate symbols to the object within their context" do
      @context.set_here :vitamin_b, "vegemite"
      @context.readeval("vitamin_b").should eq "vegemite"

      subcontext = Rouge::Context.new @context
      subcontext.set_here :joy, [:yes]
      subcontext.set_here :/, "wah"
      subcontext.readeval("joy").should eq [:yes]
      subcontext.readeval("vitamin_b").should eq "vegemite"
      subcontext.readeval("/").should eq "wah"
    end

    it "should evaluate symbols in other namespaces" do
      @context.readeval("ruby/Object").should eq Object
      @context.readeval("ruby/Exception").should eq Exception
    end

    it "should evaluate nested objects" do
      @context.readeval("ruby/Rouge.Context").should eq Rouge::Context
      @context.readeval("ruby/Errno.EAGAIN").should eq Errno::EAGAIN
    end
  end

  it "should evaluate other things to themselves" do
    Rouge.eval(@context, 4).should eq 4
    Rouge.eval(@context, "bleep bloop").should eq "bleep bloop"
    Rouge.eval(@context, :"nom it").should eq :"nom it"
    @context.readeval("{:a :b, 1 2}").to_s.should eq({:a => :b, 1 => 2}.to_s)

    l = lambda {}
    Rouge.eval(@context, l).should eq l

    o = Object.new
    Rouge.eval(@context, o).should eq o
  end

  it "should evaluate hash and vector arguments" do
    @context.readeval("{\"z\" 92, 'x ''5}").
        should eq Rouge.read("{\"z\" 92, x '5}")

    subcontext = Rouge::Context.new @context
    subcontext.set_here :lolwut, "off"
    subcontext.readeval("{lolwut [lolwut]}").
        should eq Rouge.read('{"off" ["off"]}')
  end

  describe "function calls" do
    it "should evaluate function calls" do
      subcontext = Rouge::Context.new @context
      subcontext.set_here :f, lambda {|x| "hello #{x}"}
      subcontext.readeval('(f "world")').should eq "hello world"
    end

    it "should evaluate macro calls" do
      macro = Rouge::Macro[lambda {|n, *body|
        Rouge::Cons[Rouge::Symbol[:let], Rouge::Cons[n, "example"],
          *body]
      }]

      subcontext = Rouge::Context.new @context
      subcontext.set_here :macro, macro
      subcontext.set_here :f, lambda {|x,y| x + y}
      subcontext.readeval('(macro bar (f bar bar))').should eq "exampleexample"
    end

    it "should evaluate calls with inline blocks and block binds" do
      @context.readeval('((fn [a | b] (b a)) 42 | [e] (./ e 2))').should eq 21
    end

    describe "Ruby interop" do
      describe "new object creation" do
        it "should call X.new with (X.)" do
          klass = double("klass")
          klass.should_receive(:new).with(Rouge.read('a')).and_return(:b)

          subcontext = Rouge::Context.new @context
          subcontext.set_here :klass, klass
          subcontext.readeval("(klass. 'a)").should eq :b
        end
      end

      describe "generic method calls" do
        it "should call x.y(:z) with (.y x 'z)" do
          x = double("x")
          x.should_receive(:y).with(Rouge.read('z')).and_return(:tada)

          subcontext = Rouge::Context.new @context
          subcontext.set_here :x, x
          subcontext.readeval("(.y x 'z)").should eq :tada
        end

        it "should call q.r(:s, &t) with (.r q 's | t)" do
          q = double("q")
          t = lambda {}
          q.should_receive(:r).with(Rouge.read('s'), &t).and_return(:bop)

          subcontext = Rouge::Context.new @context
          subcontext.set_here :q, q
          subcontext.set_here :t, t
          subcontext.readeval("(.r q 's | t)").should eq :bop
        end

        it "should call a.b(:c) {|d| d + 1} with (.b a 'c | [d] (.+ d 1))" do
          a = double("a")
          a.should_receive(:b) do |c, &b|
            c.should eq Rouge.read('c')
            b.call(1).should eq 2
            b.call(2).should eq 3
            b.call(3).should eq 4
            :ok
          end

          subcontext = Rouge::Context.new @context
          subcontext.set_here :a, a
          subcontext.readeval("(.b a 'c | [d] (.+ d 1))").should eq :ok
        end
      end
    end
  end
end

# vim: set sw=2 et cc=80:
