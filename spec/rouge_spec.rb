# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge do
  before do
    Rouge.boot!
  end

  describe "the rouge.core namespace" do
    before do
      @ns = Rouge[:user]
    end

    it "should contain the defn macro" do
      lambda {
        @ns[:defn].should be_an_instance_of Rouge::Macro
      }.should_not raise_exception(Rouge::Eval::BindingNotFoundError)
    end
  end

  describe "the user namespace" do
    before do
      @ns = Rouge[:user]
    end

    it "should refer rouge.builtin, rouge.core and ruby" do
      @ns.refers.should include(Rouge[:"rouge.builtin"])
      @ns.refers.should include(Rouge[:"rouge.core"])
      @ns.refers.should include(Rouge[:"ruby"])
    end
  end
end

# vim: set sw=2 et cc=80:
