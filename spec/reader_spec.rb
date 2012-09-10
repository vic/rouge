# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Reader do
  describe "the read method" do
    describe "reading numbers" do
      it "should read plain numbers" do
        RL.read("12755").should eq 12755
      end

      it "should read separated numbers" do
        RL.read("2_50_9").should eq 2509
      end
    end

    it "should read symbols" do
      RL.read("loki").should eq :loki
      RL.read("/").should eq :/
      RL.read("wah?").should eq :wah?
      RL.read("!ruby!").should eq :"!ruby!"
      RL.read("nil").should eq :nil
      RL.read("true").should eq :true
      RL.read("false").should eq :false
      RL.read("&").should eq :&
    end

    describe "keywords" do
      it "should read plain keywords" do
        RL.read(":loki").should eq RL::Keyword[:loki]
        RL.read(":/").should eq RL::Keyword[:/]
        RL.read(":wah?").should eq RL::Keyword[:wah?]
        RL.read(":nil").should eq RL::Keyword[:nil]
        RL.read(":true").should eq RL::Keyword[:true]
        RL.read(":false").should eq RL::Keyword[:false]
      end

      it "should read string-symbols" do
        RL.read(":\"!ruby!\"").should eq RL::Keyword[:"!ruby!"]
      end
    end

    describe "strings" do
      it "should read plain strings" do
        RL.read("\"akashi yo\"").should eq "akashi yo"
        RL.read("\"akashi \n woah!\"").should eq "akashi \n woah!"
      end

      it "should read escape sequences" do
        RL.read("\"here \\\" goes\"").should eq "here \" goes"
        RL.read("\"here \\\\ goes\"").should eq "here \\ goes"
        RL.read("\"\\a\\b\\e\\f\\n\\r\"").should eq "\a\b\e\f\n\r"
        RL.read("\"\\s\\t\\v\"").should eq "\s\t\v"
      end
    end

    describe "lists" do
      it "should read the empty list" do
        RL.read("()").should eq RL::Cons[]
      end

      it "should read one-element lists" do
        RL.read("(tiffany)").should eq RL::Cons[:tiffany]
        RL.read("(:raaaaash)").should eq RL::Cons[RL::Keyword[:raaaaash]]
      end

      it "should read multiple-element lists" do
        RL.read("(1 2 3)").should eq RL::Cons[1, 2, 3]
        RL.read("(true () [] \"no\")").should eq \
            RL::Cons[:true, RL::Cons[], [], "no"]
      end

      it "should read nested lists" do
        RL.read("(((3) (())) 9 ((8) (8)))").should eq \
            RL::Cons[RL::Cons[RL::Cons[3], \
            RL::Cons[RL::Cons[]]], 9, RL::Cons[RL::Cons[8], RL::Cons[8]]]
      end
    end

    describe "vectors" do
      it "should read the empty vector" do
        RL.read("[]").should eq []
      end

      it "should read one-element vectors" do
        RL.read("[tiffany]").should eq [:tiffany]
        RL.read("[:raaaaash]").should eq [RL::Keyword[:raaaaash]]
      end

      it "should read multiple-element vectors" do
        RL.read("[1 2 3]").should eq [1, 2, 3]
        RL.read("[true () [] \"no\"]").should eq [:true, RL::Cons[], [], "no"]
      end

      it "should read nested vectors" do
        RL.read("[[[3] [[]]] 9 [[8] [8]]]").should eq \
          [[[3], [[]]], 9, [[8], [8]]]
      end
    end

    describe "quotations" do
      it "should read 'X as (QUOTE X)" do
        RL.read("'x").should eq [:quote, :x]
      end

      it "should read ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
        RL.read("''('x)").should eq [:quote, [:quote, [[:quote, :x]]]]
      end
    end

    describe "maps" do
      it "should read the empty map" do
        RL.read("{}").should eq({})
      end

      it "should read one-element maps" do
        RL.read("{a 1}").should eq({:a => 1})
        RL.read("{\"quux\" (lambast)}").should eq({"quux" => [:lambast]})
      end

      it "should read multiple-element maps" do
        RL.read("{a 1 b 2}").should eq({:a => 1, :b => 2})
        RL.read("{f f, y y\nz z}").should eq({:f => :f, :y => :y, :z => :z})
      end

      it "should read nested maps" do
        RL.read("{a {z 9} b {q :q}}").should eq(
          {:a => {:z => 9}, :b => {:q => RL::Keyword[:q]}})
        RL.read("{{9 7} 5}").should eq({{9 => 7} => 5})
      end
    end

    describe "trailing-character behaviour" do
      it "should fail with trailing non-whitespace" do
        lambda {
          RL.read("hello joe")
        }.should raise_exception(RL::Reader::TrailingDataError)
      end

      it "should not fail with trailing whitespace" do
        lambda {
          RL.read("hello    \n\n\t\t  ").should eq :hello
        }.should_not raise_exception
      end
    end
  end
end

# vim: set sw=2 et cc=80:
