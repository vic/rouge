# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Eval::Builtins do
  before do
    @ns = Piret::Eval::Namespace.new :"user.spec"
    @ns.refers Piret::Eval::Namespace[:"piret.builtin"]
    @context = Piret::Eval::Context.new @ns
  end

  describe "let" do
    it "should make local bindings" do
      Piret.eval(@context, Piret.read("(let (a 42) a)")).should eq 42
      Piret.eval(@context, Piret.read("(let (a 1 a 2) a)")).should eq 2
    end
  end

  describe "quote" do
    it "should prevent evaluation" do
      Piret.eval(@context, Piret.read("(quote lmnop)")).
          should eq Piret.read('lmnop')
    end
  end

  describe "list" do
    it "should create the empty list" do
      Piret.eval(@context, Piret.read("(list)")).should eq Piret.read('()')
    end

    it "should create a unary list" do
      Piret.eval(@context, Piret.read('(list "trent")')).
          should eq Piret.read('("trent")')
      Piret.eval(@context, Piret.read("(list true)")).
          should eq Piret::Cons[true]
    end

    it "should create an n-ary list" do
      Piret.eval(@context, Piret::Cons[Piret::Symbol[:list], *(1..50)]).
          should eq Piret::Cons[*(1..50)]
    end
  end

  describe "fn" do
    it "should create a new lambda function" do
      l = Piret.eval(@context, Piret.read('(fn [] "Mystik Spiral")'))
      l.should be_an_instance_of Proc
      l.call.should eq "Mystik Spiral"
      Piret.eval(@context, Piret::Cons[l]).should eq "Mystik Spiral"
    end

    it "should create functions of correct arity" do
      lambda {
        Piret.eval(@context, Piret.read('(fn [])')).call(true)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (1 for 0)")

      lambda {
        Piret.eval(@context, Piret.read('(fn [a b c])')).call(:x, :y)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (2 for 3)")

      lambda {
        Piret.eval(@context, Piret.read('(fn [& rest])')).call()
        Piret.eval(@context, Piret.read('(fn [& rest])')).call(1)
        Piret.eval(@context, Piret.read('(fn [& rest])')).call(1, 2, 3)
        Piret.eval(@context, Piret.read('(fn [& rest])')).call(*(1..10000))
      }.should_not raise_exception
    end

    describe "argument binding" do
      it "should bind place arguments correctly" do
        Piret.eval(@context, Piret.read('(fn [a] a)')).call(:zzz).
            should eq :zzz
        Piret.eval(@context, Piret.read('(fn [a b] (list a b))')).
            call(:daria, :morgendorffer).
            should eq Piret::Cons[:daria, :morgendorffer]
      end

      it "should bind rest arguments correctly" do
        Piret.eval(@context, Piret.read('(fn (y z & rest) (list y z rest))')).
            call("where", "is", "mordialloc", "gosh").
            should eq Piret.read('("where" "is" ("mordialloc" "gosh"))')
      end

      it "should bind block arguments correctly" do
        l = lambda {}
        Piret.eval(@context, Piret.read('(fn (a | b) [a b])')).
            call("hello", &l).
            should eq ["hello", l]
      end
    end
  end

  describe "def" do
    it "should make a binding" do
      Piret.eval(@context, Piret.read("(def barge 'a)")).
          should eq Piret.read('user.spec/barge')
    end

    it "should always make a binding at the top of the namespace" do
      subcontext = Piret::Eval::Context.new @context
      Piret.eval(subcontext, Piret.read("(def sarge 'b)")).
          should eq Piret.read('user.spec/sarge')
      Piret.eval(@context, Piret.read('sarge')).should eq Piret.read('b')
    end
  end

  describe "if" do
    it "should execute one branch or the other" do
      a = mock("a")
      b = mock("b")
      a.should_receive(:call).with(any_args)
      b.should_not_receive(:call).with(any_args)
      subcontext = Piret::Eval::Context.new @context
      subcontext.set_here :a, a
      subcontext.set_here :b, b
      Piret.eval(subcontext, Piret.read('(if true (a) (b))'))
    end

    it "should not do anything in the case of a missing second branch" do
      lambda {
        Piret.eval(@context, Piret.read('(if false (a))'))
      }.should_not raise_exception
    end
  end
end

# vim: set sw=2 et cc=80:
