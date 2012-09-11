# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Reader do
  describe "reading numbers" do
    it "should read plain numbers" do
      Piret.read("12755").should eq 12755
    end

    it "should read separated numbers" do
      Piret.read("2_50_9").should eq 2509
    end
  end

  it "should read symbols" do
    Piret.read("loki").should eq Piret::Symbol[:loki]
    Piret.read("wah?").should eq Piret::Symbol[:wah?]
    Piret.read("!ruby!").should eq Piret::Symbol[:"!ruby!"]
    Piret.read("nil").should eq Piret::Symbol[:nil]
    Piret.read("true").should eq Piret::Symbol[:true]
    Piret.read("false").should eq Piret::Symbol[:false]
    Piret.read("&").should eq Piret::Symbol[:&]
    Piret.read("*").should eq Piret::Symbol[:*]
    Piret.read("-").should eq Piret::Symbol[:-]
    Piret.read("+").should eq Piret::Symbol[:+]
    Piret.read("/").should eq Piret::Symbol[:/]
    Piret.read("|").should eq Piret::Symbol[:|]
  end

  describe "keywords" do
    it "should read plain keywords" do
      Piret.read(":loki").should eq :loki
      Piret.read(":/").should eq :/
      Piret.read(":wah?").should eq :wah?
      Piret.read(":nil").should eq :nil
      Piret.read(":true").should eq :true
      Piret.read(":false").should eq :false
    end

    it "should read string-symbols" do
      Piret.read(":\"!ruby!\"").should eq :"!ruby!"
    end
  end

  describe "strings" do
    it "should read plain strings" do
      Piret.read("\"akashi yo\"").should eq "akashi yo"
      Piret.read("\"akashi \n woah!\"").should eq "akashi \n woah!"
    end

    it "should read escape sequences" do
      Piret.read("\"here \\\" goes\"").should eq "here \" goes"
      Piret.read("\"here \\\\ goes\"").should eq "here \\ goes"
      Piret.read("\"\\a\\b\\e\\f\\n\\r\"").should eq "\a\b\e\f\n\r"
      Piret.read("\"\\s\\t\\v\"").should eq "\s\t\v"
    end
  end

  describe "lists" do
    it "should read the empty list" do
      Piret.read("()").should eq Piret::Cons[]
    end

    it "should read one-element lists" do
      Piret.read("(tiffany)").should eq Piret::Cons[Piret::Symbol[:tiffany]]
      Piret.read("(:raaaaash)").
          should eq Piret::Cons[:raaaaash]
    end

    it "should read multiple-element lists" do
      Piret.read("(1 2 3)").should eq Piret::Cons[1, 2, 3]
      Piret.read("(true () [] \"no\")").
          should eq Piret::Cons[Piret::Symbol[:true], Piret::Cons[], [], "no"]
    end

    it "should read nested lists" do
      Piret.read("(((3) (())) 9 ((8) (8)))").
          should eq Piret::Cons[Piret::Cons[Piret::Cons[3],
          Piret::Cons[Piret::Cons[]]], 9,
          Piret::Cons[Piret::Cons[8], Piret::Cons[8]]]
    end
  end

  describe "vectors" do
    it "should read the empty vector" do
      Piret.read("[]").should eq []
    end

    it "should read one-element vectors" do
      Piret.read("[tiffany]").should eq [Piret::Symbol[:tiffany]]
      Piret.read("[:raaaaash]").should eq [:raaaaash]
    end

    it "should read multiple-element vectors" do
      Piret.read("[1 2 3]").should eq [1, 2, 3]
      Piret.read("[true () [] \"no\"]").
          should eq [Piret::Symbol[:true], Piret::Cons[], [], "no"]
    end

    it "should read nested vectors" do
      Piret.read("[[[3] [[]]] 9 [[8] [8]]]").
          should eq [[[3], [[]]], 9, [[8], [8]]]
    end
  end

  describe "quotations" do
    it "should read 'X as (QUOTE X)" do
      Piret.read("'x").
          should eq Piret::Cons[Piret::Symbol[:quote], Piret::Symbol[:x]]
    end

    it "should read ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
      Piret.read("''('x)").
          should eq Piret::Cons[Piret::Symbol[:quote],
                    Piret::Cons[Piret::Symbol[:quote],
                    Piret::Cons[Piret::Cons[Piret::Symbol[:quote],
                                            Piret::Symbol[:x]]]]]
    end
  end

  describe "maps" do
    it "should read the empty map" do
      Piret.read("{}").should eq({})
    end

    it "should read one-element maps" do
      Piret.read("{a 1}").should eq({Piret::Symbol[:a] => 1})
      Piret.read("{\"quux\" [lambast]}").
          should eq({"quux" => [Piret::Symbol[:lambast]]})
    end

    it "should read multiple-element maps" do
      Piret.read("{:a 1 :b 2}").should eq({:a => 1, :b => 2})
      Piret.read("{:f :f, :y :y\n:z :z}").
          should eq({:f => :f, :y => :y, :z => :z})
    end

    it "should read nested maps" do
      Piret.read("{:a {:z 9} :b {:q q}}").should eq(
        {:a => {:z => 9}, :b => {:q => Piret::Symbol[:q]}})
      Piret.read("{{9 7} 5}").should eq({{9 => 7} => 5})
    end
  end

  describe "trailing-character behaviour" do
    it "should fail with trailing non-whitespace" do
      lambda {
        Piret.read("hello joe")
      }.should raise_exception(Piret::Reader::TrailingDataError)
    end

    it "should not fail with trailing whitespace" do
      lambda {
        Piret.read(":hello    \n\n\t\t  ").should eq :hello
      }.should_not raise_exception
    end

    it "should deal with whitespace in strange places" do
      lambda {
        Piret.read("[1 ]").should eq [1]
        Piret.read(" [   2 ] ").should eq [2]
      }.should_not raise_exception
    end
  end

  describe "empty reads" do
    it "should fail on empty reads" do
      lambda {
        Piret.read("")
      }.should raise_exception(Piret::Reader::EndOfDataError)

      lambda {
        Piret.read("    \n         ")
      }.should raise_exception(Piret::Reader::EndOfDataError)
    end
  end

  describe "comments" do
    it "should ignore comments" do
      Piret.read("42 ;what!").should eq 42
      Piret.read("[42 ;what!\n15]").should eq [42, 15]

      lambda {
        Piret.read(";what!")
      }.should raise_exception(Piret::Reader::EndOfDataError)

      Piret.read(";what!\nhmm").should eq Piret::Symbol[:hmm]
    end
  end
end

# vim: set sw=2 et cc=80:
