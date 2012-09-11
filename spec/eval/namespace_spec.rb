# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Eval::Namespace do
  describe "the [] method" do
    it "should vivify non-extant namespaces" do
      Piret::Eval::Namespace.exists?(:vivify_test).should eq false
      Piret::Eval::Namespace[:vivify_test].
          should be_an_instance_of Piret::Eval::Namespace
      Piret::Eval::Namespace.exists?(:vivify_test).should eq true
    end
  end

  describe "the Piret[] shortcut" do
    it "should directly call the [] method" do
      Piret::Eval::Namespace.should_receive(:[]).with(:trazzle)
      Piret[:trazzle]
    end
  end

  describe "the refers method" do
    it "should cause items in one namespace to be locatable from the other" do
      abc = Piret::Eval::Namespace.new :abc
      xyz = Piret::Eval::Namespace.new :xyz

      xyz.refers abc

      abc.set_here :hello, :wow
      xyz[:hello].should eq :wow
    end
  end

  describe "the piret namespace" do
    before do
      @ns = Piret[:piret]
    end

    it "should contain elements from Piret::Eval::Builtins" do
      @ns[:let].should be_an_instance_of Piret::Builtin
      @ns[:quote].should be_an_instance_of Piret::Builtin
    end

    it "should contain fundamental objects" do
      @ns[:nil].should eq nil
      @ns[:true].should eq true
      @ns[:false].should eq false
    end

    it "should not find objects from ruby" do
      lambda {
        @ns[:Float]
      }.should raise_exception(Piret::Eval::BindingNotFoundError)
      lambda {
        @ns[:String]
      }.should raise_exception(Piret::Eval::BindingNotFoundError)
    end

    it "should have a name" do
      @ns.name.should eq :piret
    end
  end

  describe "the ruby namespace" do
    before do
      @ns = Piret::Eval::Namespace[:ruby]
    end

    it "should contain elements from Kernel" do
      @ns[:Hash].should eq Hash
      @ns[:Fixnum].should eq Fixnum
    end

    it "should have a name" do
      @ns.name.should eq :ruby
    end
  end
end

# vim: set sw=2 et cc=80:
