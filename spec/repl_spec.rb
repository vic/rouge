# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::REPL do
  describe "the context" do
    before do
      @context = Piret::REPL.context
    end

    it "should be in the user namespace" do
      @context.ns.should be Piret[:user]
    end

    it "should refer piret.builtin and ruby from user" do
      @context.ns.refers.should include(Piret[:"piret.builtin"])
      @context.ns.refers.should include(Piret[:"ruby"])
    end
  end
end

# vim: set sw=2 et cc=80:
