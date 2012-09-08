# encoding: utf-8
require 'spec_helper'
require 'core'

describe Keyword do
  describe "the constructor" do
    it "should return a new keyword" do
      Keyword.new(:abc).should be_an_instance_of(Keyword)
    end
  end

  describe "keyword equality" do
    it "should be true for two keyword with the same underlying symbol" do
      Keyword.new(:xyz).should eq Keyword.new(:xyz)
    end
  end
end

describe Symbol do
  describe "the to_keyword method" do
    it "should return a keyword for the given symbol" do
      :abc.to_keyword.should eq Keyword.new(:abc)
    end
  end
end

# vim: set sw=2 et cc=80:
