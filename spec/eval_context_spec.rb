# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval::Context do
  before do
    @a = RL::Eval::Context.new nil
    @ab = RL::Eval::Context.new @a
    @abb = RL::Eval::Context.new @ab
    @ac = RL::Eval::Context.new @a
    @in_rl = RL::Eval::Context.new RL::Eval::Namespace[:rl]
    @in_rl_nested = RL::Eval::Context.new @in_rl

    @a.set_here :root, 42
    @ab.set_here :root, 80
    @ac.set_here :non, 50
  end

  describe "the [] method" do
    it "should get the closest binding" do
      @a[:root].should eq 42
      @ab[:root].should eq 80
      @abb[:root].should eq 80
      @ac[:root].should eq 42
      @in_rl[:let].should be_an_instance_of RL::Builtin
    end

    it "should raise an exception if a binding is not found" do
      lambda {
        @a[:non]
      }.should raise_exception(RL::Eval::Context::BindingNotFoundError)
    end
  end

  describe "the ns method" do
    it "should get the namespace of a context that has one" do
      @in_rl.ns.should eq RL::Eval::Namespace[:rl]
    end

    it "should get the namespace of a nested context that has one" do
      @in_rl_nested.ns.should eq RL::Eval::Namespace[:rl]
    end

    it "should return nil if a context has none" do
      @a.ns.should eq nil
      @ab.ns.should eq nil
    end
  end

  describe "the set_here method" do
    it "should set in the given context, shadowing outer bindings" do
      @ac.set_here :root, 90
      @ac[:root].should eq 90
      @a[:root].should eq 42
    end
  end

  describe "the set_lexical method" do
    it "should set in the closest context" do
      @abb.set_lexical :root, 777
      @abb[:root].should eq 777
      @ab[:root].should eq 777
      @a[:root].should eq 42
    end

    it "should raise an exception if a closest binding is not found" do
      lambda {
        @abb.set_lexical :non, 10
      }.should raise_exception(RL::Eval::Context::BindingNotFoundError)
    end
  end
end

# vim: set sw=2 et cc=80:
