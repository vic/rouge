# encoding: utf-8
require 'spec_helper'
require 'reader'

describe Reader do
  describe "the read method" do
    describe "reading numbers" do
      it "should read plain numbers" do
        Reader.read("12755").should eq 12755
      end

      it "should read separated numbers" do
        Reader.read("2_50_9").should eq 2509
      end
    end

    it "should read symbols" do
      Reader.read("loki").should eq :loki
      Reader.read("/").should eq :/
      Reader.read("wah?").should eq :wah?
      Reader.read("!ruby!").should eq :"!ruby!"
      Reader.read("nil").should eq :nil
      Reader.read("true").should eq :true
      Reader.read("false").should eq :false
    end

    describe "keywords" do
      it "should read plain keywords" do
        Reader.read(":loki").should eq Keyword[:loki]
        Reader.read(":/").should eq Keyword[:/]
        Reader.read(":wah?").should eq Keyword[:wah?]
        Reader.read(":nil").should eq Keyword[:nil]
        Reader.read(":true").should eq Keyword[:true]
        Reader.read(":false").should eq Keyword[:false]
      end

      it "should read string-symbols" do
        Reader.read(":\"!ruby!\"").should eq Keyword[:"!ruby!"]
      end
    end

    describe "strings" do
      it "should read plain strings" do
        Reader.read("\"akashi yo\"").should eq "akashi yo"
        Reader.read("\"akashi \n woah!\"").should eq "akashi \n woah!"
      end

      it "should read escape sequences" do
        Reader.read("\"here \\\" goes\"").should eq "here \" goes"
        Reader.read("\"here \\\\ goes\"").should eq "here \\ goes"
        Reader.read("\"\\a\\b\\e\\f\\n\\r\"").should eq "\a\b\e\f\n\r"
        Reader.read("\"\\s\\t\\v\"").should eq "\s\t\v"
      end
    end

    describe "lists" do
      it "should read the empty list" do
        Reader.read("()").should eq []
      end

      it "should read one-element lists" do
        Reader.read("(tiffany)").should eq [:tiffany]
        Reader.read("(:raaaaash)").should eq [Keyword[:raaaaash]]
      end

      it "should read multiple-element lists" do
        Reader.read("(1 2 3)").should eq [1, 2, 3]
        Reader.read("(true () \"no\")").should eq [:true, [], "no"]
      end

      it "should read nested lists" do
        Reader.read("(((3) (())) 9 ((8) (8)))").should eq \
          [[[3], [[]]], 9, [[8], [8]]]
      end
    end

    describe "quotations" do
      it "should read 'X as (QUOTE X)" do
        Reader.read("'x").should eq [:quote, :x]
      end

      it "should read ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
        Reader.read("''('x)").should eq [:quote, [:quote, [[:quote, :x]]]]
      end
    end

    describe "maps" do
      it "should read the empty map" do
        Reader.read("{}").should eq({})
      end

      it "should read one-element maps" do
        Reader.read("{a 1}").should eq({:a => 1})
        Reader.read("{\"quux\" (lambast)}").should eq({"quux" => [:lambast]})
      end

      it "should read multiple-element maps" do
        Reader.read("{a 1 b 2}").should eq({:a => 1, :b => 2})
        Reader.read("{f f, y y\nz z}").should eq(
          {:f => :f, :y => :y, :z => :z})
      end

      it "should read nested maps" do
        Reader.read("{a {z 9} b {q :q}}").should eq(
          {:a => {:z => 9}, :b => {:q => Keyword[:q]}})
        Reader.read("{{9 7} 5}").should eq(
          {{9 => 7} => 5})
      end
    end
  end
end

# vim: set sw=2 et cc=80:
