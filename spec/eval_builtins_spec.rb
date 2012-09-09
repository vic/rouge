# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval::Builtins do
  before do
    @context = RL::Eval::Context.toplevel
  end

  describe "let" do
    it "should make local bindings" do
      RL.eval(@context, [:let, [:a, 42], :a]).should eq 42
      RL.eval(@context, [:let, [:a, 1, :a, 2], :a]).should eq 2
    end
  end

  describe "quote" do
    it "should prevent evaluation" do
      RL.eval(@context, [:quote, :lmnop]).should eq :lmnop
    end
  end

  describe "list" do
    it "should create the empty list" do
      RL.eval(@context, [:list]).should eq []
    end

    it "should create a unary list" do
      RL.eval(@context, [:list, "trent"]).should eq ["trent"]
      RL.eval(@context, [:list, true]).should eq [true]
    end

    it "should create an n-ary list" do
      RL.eval(@context, [:list, *(1..50)]).should eq [*(1..50)]
    end
  end

  describe "fn" do
    it "should create a new lambda function" do
      l = RL.eval(@context, [:fn, [], "Mystik Spiral"])
      l.should be_an_instance_of Proc
      l.call.should eq "Mystik Spiral"
      RL.eval(@context, [l]).should eq "Mystik Spiral"
    end

    it "should create functions of correct arity" do
      lambda {
        RL.eval(@context, [:fn, []]).call(true)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (1 for 0)")

      lambda {
        RL.eval(@context, [:fn, [:a, :b, :c]]).call(:x, :y)
      }.should raise_exception(
          ArgumentError, "wrong number of arguments (2 for 3)")

      lambda {
        RL.eval(@context, [:fn, [:&, :rest]]).call()
        RL.eval(@context, [:fn, [:&, :rest]]).call(1)
        RL.eval(@context, [:fn, [:&, :rest]]).call(1, 2, 3)
        RL.eval(@context, [:fn, [:&, :rest]]).call(*(1..10000))
      }.should_not raise_exception
    end

    describe "argument binding" do
      it "should bind place arguments correctly" do
        RL.eval(@context, [:fn, [:a], :a]).call(:zzz).should eq :zzz
        RL.eval(@context, [:fn, [:a, :b], [:list, :a, :b]]).
            call(:daria, :morgendorffer).should eq [:daria, :morgendorffer]
      end

      it "should bind rest arguments correctly" do
        RL.eval(@context, [:fn, [:y, :z, :&, :rest], [:list, :y, :z, :rest]]).
            call("where", "is", "mordialloc", "gosh").should eq \
            ["where", "is", ["mordialloc", "gosh"]]
      end
    end
  end
end

# vim: set sw=2 et cc=80:
