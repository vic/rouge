# encoding: utf-8
require 'spec_helper'
require 'reader'

describe Reader do
  describe "the read method" do
    describe "reading numbers" do
      it "should read plain numbers" do
        Reader.read("12755").should eq(12755)
      end

      it "should read separated numbers" do
        Reader.read("2_50_9").should eq(2509)
      end
    end

    it "should read symbols" do
      Reader.read("loki").should eq(:loki)
    end
  end
end

# vim: set sw=2 et cc=80:
