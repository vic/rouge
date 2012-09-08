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

    it "should read atoms" do
      Reader.read("loki").should eq(:loki.atom)
      Reader.read("/").should eq(:/.atom)
      Reader.read("wah?").should eq(:wah?.atom)
      Reader.read("!ruby!").should eq(:"!ruby!".atom)
      Reader.read("nil").should eq(:nil.atom)
      Reader.read("true").should eq(:true.atom)
      Reader.read("false").should eq(:false.atom)
    end

    describe "symbols" do
      it "should read plain symbols" do
        Reader.read(":loki").should eq(:loki)
        Reader.read(":/").should eq(:/)
        Reader.read(":wah?").should eq(:wah?)
        Reader.read(":nil").should eq(:nil)
        Reader.read(":true").should eq(:true)
        Reader.read(":false").should eq(:false)
      end

      it "should read string-symbols" do
        Reader.read(":\"!ruby!\"").should eq(:"!ruby!")
      end
    end

    describe "strings" do
      it "should read plain strings" do
        Reader.read("\"akashi yo\"").should eq("akashi yo")
        Reader.read("\"akashi \n woah!\"").should eq("akashi \n woah!")
      end

      it "should read escape sequences" do
        Reader.read("\"here \\\" goes\"").should eq("here \" goes")
        Reader.read("\"here \\\\ goes\"").should eq("here \\ goes")
        Reader.read("\"\\a\\b\\e\\f\\n\\r\"").should eq("\a\b\e\f\n\r")
        Reader.read("\"\\s\\t\\v\"").should eq("\s\t\v")
      end
    end
  end
end

# vim: set sw=2 et cc=80:
