# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Eval::Context do
  before do
    @a = RL::Eval::Context.new nil
    @ab = RL::Eval::Context.new @a
    @abb = RL::Eval::Context.new @ab
    @ac = RL::Eval::Context.new @a

    @a.set_here :root, 42
    @ab.set_here :root, 80
    @ac.set_here :non, 50
  end

  describe "the toplevel context" do
    before do
      @context = RL::Eval::Context.toplevel
    end

    it "should contain elements from RL::Eval::Builtins" do
      @context[:let].should be_an_instance_of RL::Builtin
      @context[:quote].should be_an_instance_of RL::Builtin
    end

    it "should contain fundamental objects" do
      @context[:nil].should eq nil
      @context[:true].should eq true
      @context[:false].should eq false
    end
  end

  describe "the [] method" do
    it "should get the closest binding" do
      @a[:root].should eq 42
      @ab[:root].should eq 80
      @abb[:root].should eq 80
      @ac[:root].should eq 42
    end

    it "should raise an exception if a binding is not found" do
      lambda {
        @a[:non]
      }.should raise_exception(RL::Eval::Context::BindingNotFoundError)
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
