# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Builtins do
  before do
    @ns = Rouge::Namespace.new :"user.spec"
    @ns.refer Rouge::Namespace[:"rouge.builtin"]
    @context = Rouge::Context.new @ns
  end

  describe "let" do
    it "should make local bindings" do
      Rouge.eval(@context, Rouge.read("(let (a 42) a)")).should eq 42
      Rouge.eval(@context, Rouge.read("(let (a 1 a 2) a)")).should eq 2
    end
  end

  describe "quote" do
    it "should prevent evaluation" do
      Rouge.eval(@context, Rouge.read("(quote lmnop)")).
          should eq Rouge.read('lmnop')
    end
  end

  describe "fn" do
    it "should create a new lambda function" do
      l = Rouge.eval(@context, Rouge.read('(fn [] "Mystik Spiral")'))
      l.should be_an_instance_of Proc
      l.call.should eq "Mystik Spiral"
      Rouge.eval(@context, Rouge::Cons[l]).should eq "Mystik Spiral"
    end

    it "should create functions of correct arity" do
      lambda {
        Rouge.eval(@context, Rouge.read('(fn [])')).call(true)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (1 for 0)")

      lambda {
        Rouge.eval(@context, Rouge.read('(fn [a b c])')).call(:x, :y)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (2 for 3)")

      lambda {
        Rouge.eval(@context, Rouge.read('(fn [& rest])')).call()
        Rouge.eval(@context, Rouge.read('(fn [& rest])')).call(1)
        Rouge.eval(@context, Rouge.read('(fn [& rest])')).call(1, 2, 3)
        Rouge.eval(@context, Rouge.read('(fn [& rest])')).call(*(1..10000))
      }.should_not raise_exception
    end

    describe "argument binding" do
      it "should bind place arguments correctly" do
        Rouge.eval(@context, Rouge.read('(fn [a] a)')).call(:zzz).
            should eq :zzz
        Rouge.eval(@context, Rouge.read('(fn [a b] [a b])')).
            call(:daria, :morgendorffer).
            should eq [:daria, :morgendorffer]
      end

      it "should bind rest arguments correctly" do
        Rouge.eval(@context, Rouge.read('(fn (y z & rest) [y z rest])')).
            call("where", "is", "mordialloc", "gosh").
            should eq Rouge.read('["where" "is" ("mordialloc" "gosh")]')
      end

      it "should bind block arguments correctly" do
        l = lambda {}
        Rouge.eval(@context, Rouge.read('(fn (a | b) [a b])')).
            call("hello", &l).
            should eq ["hello", l]
      end
    end
  end

  describe "def" do
    it "should make a binding" do
      Rouge.eval(@context, Rouge.read("(def barge 'a)")).
          should eq Rouge.read('user.spec/barge')
    end

    it "should always make a binding at the top of the namespace" do
      subcontext = Rouge::Context.new @context
      Rouge.eval(subcontext, Rouge.read("(def sarge 'b)")).
          should eq Rouge.read('user.spec/sarge')
      Rouge.eval(@context, Rouge.read('sarge')).should eq Rouge.read('b')
    end
  end

  describe "if" do
    it "should execute one branch or the other" do
      a = mock("a")
      b = mock("b")
      a.should_receive(:call).with(any_args)
      b.should_not_receive(:call).with(any_args)
      subcontext = Rouge::Context.new @context
      subcontext.set_here :a, a
      subcontext.set_here :b, b
      Rouge.eval(subcontext, Rouge.read('(if true (a) (b))'))
    end

    it "should not do anything in the case of a missing second branch" do
      lambda {
        Rouge.eval(@context, Rouge.read('(if false (a))'))
      }.should_not raise_exception
    end
  end

  describe "do" do
    it "should return nil with no arguments" do
      Rouge.eval(@context, Rouge.read('(do)')).should eq nil
    end

    it "should evaluate and return one argument" do
      subcontext = Rouge::Context.new @context
      subcontext.set_here :x, lambda {4}
      Rouge.eval(subcontext, Rouge.read('(do (x))')).should eq 4
    end

    it "should evaluate multiple arguments and return the last value" do
      a = mock("a")
      a.should_receive(:call)
      subcontext = Rouge::Context.new @context
      subcontext.set_here :a, a
      subcontext.set_here :b, lambda {7}
      Rouge.eval(subcontext, Rouge.read('(do (a) (b))')).should eq 7
    end
  end

  describe "ns" do
    before do
      Rouge::Namespace.destroy :"user.spec2"
    end

    it "should create and use a new context pointing at a given ns" do
      Rouge.eval(@context, Rouge.read('(do (ns user.spec2) (def nope 8))'))
      Rouge[:"user.spec2"][:nope].should eq 8
      lambda {
        @context[:nope]
      }.should raise_exception(Rouge::Eval::BindingNotFoundError)
    end

    it "should support the :use option" do
      Rouge.eval(@context, Rouge.read(<<-ROUGE)).should eq "<3"
        (do
          (ns user.spec2)
          (def love "<3")

          (ns user.spec3
            (:use user.spec2))
          love)
      ROUGE
    end
  end

  describe "defmacro" do
    it "should return a reference to the created macro" do
      Rouge.eval(@context, Rouge.read("(defmacro a [] 'b)")).
          should eq Rouge::Symbol[:"user.spec/a"]
    end

    it "should evaluate in the defining context" do
      # XXX: normal Clojure behaviour would be to fail immediately here.  This
      # is contrary to Ruby's own lambdas, however.  Careful thought required;
      # we may need a more thorough compilation stage which expands macros and
      # then does a once-over to detect for symbols without bindings.
      # v-- start surprising (non-Clojurish)
      Rouge.eval(@context, Rouge.read("(defmacro a [] b)"))

      lambda {
        Rouge.eval(@context, Rouge.read('(a)'))
      }.should raise_exception(Rouge::Eval::BindingNotFoundError, "b")

      lambda {
        Rouge.eval(@context, Rouge.read('(let [b 4] (a))'))
      }.should raise_exception(Rouge::Eval::BindingNotFoundError, "b")
      # ^-- end surprising

      Rouge.eval(@context, Rouge.read("(def b 'c)"))

      lambda {
        Rouge.eval(@context, Rouge.read("(defmacro a [] b)"))
      }.should_not raise_exception
    end

    it "should expand in the calling context" do
      Rouge.eval(@context, Rouge.read("(def b 'c)"))
      Rouge.eval(@context, Rouge.read("(defmacro a [] b)"))

      lambda {
        Rouge.eval(@context, Rouge.read("(a)"))
      }.should raise_exception(Rouge::Eval::BindingNotFoundError, "c")

      Rouge.eval(@context, Rouge.read("(let [c 9] (a))")).should eq 9
    end
  end

  describe "apply" do
    before do
      @a = lambda {|*args| args}
      @subcontext = Rouge::Context.new @context
      @subcontext.set_here :a, @a
    end

    it "should call a function with the argument list" do
      Rouge.eval(@subcontext, Rouge.read("(apply a [1 2 3])")).
          should eq [1, 2, 3]
      Rouge.eval(@subcontext, Rouge.read("(apply a '(1 2 3))")).
          should eq [1, 2, 3]
    end

    it "should call a function with intermediate arguments" do
      Rouge.eval(@subcontext, Rouge.read("(apply a 8 9 [1 2 3])")).
          should eq [8, 9, 1, 2, 3]
      Rouge.eval(@subcontext, Rouge.read("(apply a 8 9 '(1 2 3))")).
          should eq [8, 9, 1, 2, 3]
    end
  end
end

# vim: set sw=2 et cc=80:
