# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret do
  before do
    Piret.boot!
  end

  describe "the piret.core namespace" do
    before do
      @ns = Piret[:user]
    end

    it "should contain the defn macro" do
      lambda {
        @ns[:defn].should be_an_instance_of Piret::Macro
      }.should_not raise_exception(Piret::Eval::BindingNotFoundError)
    end
  end

  describe "the user namespace" do
    before do
      @ns = Piret[:user]
    end

    it "should refer piret.builtin, piret.core and ruby" do
      @ns.refers.should include(Piret[:"piret.builtin"])
      @ns.refers.should include(Piret[:"piret.core"])
      @ns.refers.should include(Piret[:"ruby"])
    end
  end
end

# vim: set sw=2 et cc=80:
