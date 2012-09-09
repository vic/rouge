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
end

# vim: set sw=2 et cc=80:
