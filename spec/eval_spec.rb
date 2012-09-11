# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Eval do
  before do
    @context = Piret::Eval::Context.new Piret[:piret]
  end

  it "should evaluate quotations to their unquoted form" do
    Piret.eval(@context, Piret.read("'x")).should eq Piret.read("x")
    Piret.eval(@context, Piret.read("'':zzy")).should eq Piret.read("':zzy")
  end

  describe "symbols" do
    it "should evaluate symbols to the object within their context" do
      @context.set_here :vitamin_b, "vegemite"
      Piret.eval(@context, Piret.read("vitamin_b")).should eq "vegemite"

      subcontext = Piret::Eval::Context.new @context
      subcontext.set_here :joy, [:yes]
      Piret.eval(subcontext, Piret.read("joy")).should eq [:yes]
    end

    it "should evaluate symbols in other namespaces" do
      Piret.eval(@context, Piret.read("ruby/Object")).should eq Object
      Piret.eval(@context, Piret.read("ruby/Exception")).should eq Exception
    end

    it "should evaluate nested objects" do
      Piret.eval(@context, Piret.read("ruby/Piret.Eval.Context")).
          should eq Piret::Eval::Context
      Piret.eval(@context, Piret.read("ruby/Errno.EAGAIN")).
          should eq Errno::EAGAIN
    end
  end

  it "should evaluate other things to themselves" do
    Piret.eval(@context, 4).should eq 4
    Piret.eval(@context, "bleep bloop").should eq "bleep bloop"
    Piret.eval(@context, :"nom it").should eq :"nom it"
    Piret.eval(@context, Piret.read("{:a :b, 1 2}")).to_s.
        should eq({:a => :b, 1 => 2}.to_s)

    l = lambda {}
    Piret.eval(@context, l).should eq l

    o = Object.new
    Piret.eval(@context, o).should eq o
  end

  it "should evaluate hash and vector arguments" do
    Piret.eval(@context, Piret.read("{\"z\" 92, 'x ''5}")).
        should eq Piret.read("{\"z\" 92, x '5}")

    subcontext = Piret::Eval::Context.new @context
    subcontext.set_here :lolwut, "off"
    Piret.eval(subcontext, Piret.read("{lolwut [lolwut]}")).
        should eq Piret.read('{"off" ["off"]}')
  end

  describe "function calls" do
    it "should evaluate function calls" do
      subcontext = Piret::Eval::Context.new @context
      subcontext.set_here :f, lambda {|x| "hello #{x}"}
      Piret.eval(subcontext, Piret.read('(f "world")')).
          should eq "hello world"
    end

    it "should evaluate macro calls" do
      macro = Piret::Macro[lambda {|n, *body|
        Piret::Cons[Piret::Symbol[:let], Piret::Cons[n, "example"],
          *body]
      }]

      subcontext = Piret::Eval::Context.new @context
      subcontext.set_here :macro, macro
      subcontext.set_here :f, lambda {|x,y| x + y}
      Piret.eval(subcontext, Piret.read('(macro bar (f bar bar))')).
          should eq "exampleexample"
    end

    it "should evaluate calls with splats" do
      Piret.eval(@context, Piret.read('((fn [a b] [b a]) 1 & [2])')).
          should eq [2, 1]

      Piret.eval(@context, Piret.read('((fn [a b] [b a]) & [1 2])')).
          should eq [2, 1]

      Piret.eval(@context, Piret.read("((fn [a b] [b a]) & '(1 2))")).
          should eq [2, 1]

      Piret.eval(@context, Piret.read("((fn [a b] [b a]) 1 2 & ())")).
          should eq [2, 1]

      Piret.eval(@context, Piret.read("((fn [a b] [b a]) 1 2 & nil)")).
          should eq [2, 1]
    end

    it "should evaluate calls with inline blocks and block binds" do
      Piret.eval(@context,
                 Piret.read('((fn [a | b] (b a)) 42 | [e] (./ e 2))')).
          should eq 21
    end

    describe "Ruby interop" do
      describe "new object creation" do
        it "should call X.new with (X.)" do
          klass = double("klass")
          klass.should_receive(:new).with(Piret.read('a')).and_return(:b)

          subcontext = Piret::Eval::Context.new @context
          subcontext.set_here :klass, klass
          Piret.eval(subcontext, Piret.read("(klass. 'a)")).should eq :b
        end
      end

      describe "generic method calls" do
        it "should call x.y(:z) with (.y x 'z)" do
          x = double("x")
          x.should_receive(:y).with(Piret.read('z')).and_return(:tada)

          subcontext = Piret::Eval::Context.new @context
          subcontext.set_here :x, x
          Piret.eval(subcontext, Piret.read("(.y x 'z)")).should eq :tada
        end

        it "should call e.f(:g, *h) with (.e f 'g & h)" do
          f = double("f")
          h = [1, 9]
          f.should_receive(:e).with(Piret.read('g'), *h).and_return(:yada)

          subcontext = Piret::Eval::Context.new @context
          subcontext.set_here :f, f
          subcontext.set_here :h, h
          Piret.eval(subcontext, Piret.read("(.e f 'g & h)")).should eq :yada
        end

        it "should call q.r(:s, &t) with (.r q 's | t)" do
          q = double("q")
          t = lambda {}
          q.should_receive(:r).with(Piret.read('s'), &t).and_return(:bop)

          subcontext = Piret::Eval::Context.new @context
          subcontext.set_here :q, q
          subcontext.set_here :t, t
          Piret.eval(subcontext, Piret.read("(.r q 's | t)")).should eq :bop
        end

        it "should call a.b(:c) {|d| d + 1} with (.b a 'c | [d] (.+ d 1))" do
          a = double("a")
          a.should_receive(:b) do |c, &b|
            c.should eq Piret.read('c')
            b.call(1).should eq 2
            b.call(2).should eq 3
            b.call(3).should eq 4
            :ok
          end

          subcontext = Piret::Eval::Context.new @context
          subcontext.set_here :a, a
          Piret.eval(subcontext, Piret.read("(.b a 'c | [d] (.+ d 1))")).
              should eq :ok
        end
      end
    end
  end
end

# vim: set sw=2 et cc=80:
