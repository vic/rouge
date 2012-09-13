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
      @context.readeval("(let (a 42) a)").should eq 42
      @context.readeval("(let (a 1 a 2) a)").should eq 2
    end
  end

  describe "quote" do
    it "should prevent evaluation" do
      @context.readeval("(quote lmnop)").should eq Rouge.read('lmnop')
    end
  end

  describe "fn" do
    it "should create a new lambda function" do
      l = @context.readeval('(fn [] "Mystik Spiral")')
      l.should be_an_instance_of Proc
      l.call.should eq "Mystik Spiral"
      Rouge.eval(@context, Rouge::Cons[l]).should eq "Mystik Spiral"
    end

    it "should create functions of correct arity" do
      lambda {
        @context.readeval('(fn [])').call(true)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (1 for 0)")

      lambda {
        @context.readeval('(fn [a b c])').call(:x, :y)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (2 for 3)")

      lambda {
        @context.readeval('(fn [& rest])').call()
        @context.readeval('(fn [& rest])').call(1)
        @context.readeval('(fn [& rest])').call(1, 2, 3)
        @context.readeval('(fn [& rest])').call(*(1..10000))
      }.should_not raise_exception
    end

    describe "argument binding" do
      it "should bind place arguments correctly" do
        @context.readeval('(fn [a] a)').call(:zzz).should eq :zzz
        @context.readeval('(fn [a b] [a b])').
            call(:daria, :morgendorffer).
            should eq [:daria, :morgendorffer]
      end

      it "should bind rest arguments correctly" do
        @context.readeval('(fn (y z & rest) [y z rest])').
            call("where", "is", "mordialloc", "gosh").
            should eq Rouge.read('["where" "is" ("mordialloc" "gosh")]')
      end

      it "should bind block arguments correctly" do
        l = lambda {}
        @context.readeval('(fn (a | b) [a b])').
            call("hello", &l).
            should eq ["hello", l]
      end
    end
  end

  describe "def" do
    it "should create and intern a var" do
      @context.readeval("(def barge)").
          should eq Rouge::Var.new(:"user.spec/barge")
    end

    it "should always make a binding at the top of the namespace" do
      subcontext = Rouge::Context.new @context
      subcontext.readeval("(def sarge :b)").
          should eq Rouge::Var.new(:"user.spec/sarge", :b)
      @context.readeval('sarge').should eq :b
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
      subcontext.readeval('(if true (a) (b))')
    end

    it "should not do anything in the case of a missing second branch" do
      lambda {
        @context.readeval('(if false (a))')
      }.should_not raise_exception
    end
  end

  describe "do" do
    it "should return nil with no arguments" do
      @context.readeval('(do)').should eq nil
    end

    it "should evaluate and return one argument" do
      subcontext = Rouge::Context.new @context
      subcontext.set_here :x, lambda {4}
      subcontext.readeval('(do (x))').should eq 4
    end

    it "should evaluate multiple arguments and return the last value" do
      a = mock("a")
      a.should_receive(:call)
      subcontext = Rouge::Context.new @context
      subcontext.set_here :a, a
      subcontext.set_here :b, lambda {7}
      subcontext.readeval('(do (a) (b))').should eq 7
    end
  end

  describe "ns" do
    before do
      Rouge::Namespace.destroy :"user.spec2"
    end

    it "should create and use a new context pointing at a given ns" do
      @context.readeval('(do (ns user.spec2) (def nope 8))')
      Rouge[:"user.spec2"][:nope].root.should eq 8
      lambda {
        @context[:nope]
      }.should raise_exception(Rouge::Namespace::VarNotFoundError)
    end

    it "should support the :use option" do
      @context.readeval(<<-ROUGE).should eq "<3"
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
      @context.readeval("(defmacro a [] 'b)").
          should eq Rouge::Symbol[:"user.spec/a"]
    end

    it "should evaluate in the defining context" do
      # XXX: normal Clojure behaviour would be to fail immediately here.  This
      # is contrary to Ruby's own lambdas, however.  Careful thought required;
      # we may need a more thorough compilation stage which expands macros and
      # then does a once-over to detect for symbols without bindings.
      # v-- start surprising (non-Clojurish)
      @context.readeval("(defmacro a [] b)")

      lambda {
        @context.readeval('(a)')
      }.should raise_exception(Rouge::Namespace::VarNotFoundError, "b")

      lambda {
        @context.readeval('(let [b 4] (a))')
      }.should raise_exception(Rouge::Namespace::VarNotFoundError, "b")
      # ^-- end surprising

      @context.readeval("(def b 'c)")

      lambda {
        @context.readeval("(defmacro a [] b)")
      }.should_not raise_exception
    end

    it "should expand in the calling context" do
      @context.readeval("(def b 'c)")
      @context.readeval("(defmacro a [] b)")

      lambda {
        @context.readeval("(a)")
      }.should raise_exception(Rouge::Namespace::VarNotFoundError, "c")

      @context.readeval("(let [c 9] (a))").should eq 9
    end
  end

  describe "apply" do
    before do
      @a = lambda {|*args| args}
      @subcontext = Rouge::Context.new @context
      @subcontext.set_here :a, @a
    end

    it "should call a function with the argument list" do
      @subcontext.readeval("(apply a [1 2 3])").should eq [1, 2, 3]
      @subcontext.readeval("(apply a '(1 2 3))").should eq [1, 2, 3]
    end

    it "should call a function with intermediate arguments" do
      @subcontext.readeval("(apply a 8 9 [1 2 3])").should eq [8, 9, 1, 2, 3]
      @subcontext.readeval("(apply a 8 9 '(1 2 3))").should eq [8, 9, 1, 2, 3]
    end
  end
end

# vim: set sw=2 et cc=80:
