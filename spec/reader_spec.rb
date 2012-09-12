# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Reader do
  describe "reading numbers" do
    it "should read plain numbers" do
      Rouge.read("12755").should eq 12755
    end

    it "should read separated numbers" do
      Rouge.read("2_50_9").should eq 2509
    end
  end

  it "should read symbols" do
    Rouge.read("loki").should eq Rouge::Symbol[:loki]
    Rouge.read("wah?").should eq Rouge::Symbol[:wah?]
    Rouge.read("!ruby!").should eq Rouge::Symbol[:"!ruby!"]
    Rouge.read("nil").should eq Rouge::Symbol[:nil]
    Rouge.read("nil").should eq nil
    Rouge.read("true").should eq Rouge::Symbol[:true]
    Rouge.read("true").should eq true
    Rouge.read("false").should eq Rouge::Symbol[:false]
    Rouge.read("false").should eq false
    Rouge.read("&").should eq Rouge::Symbol[:&]
    Rouge.read("*").should eq Rouge::Symbol[:*]
    Rouge.read("-").should eq Rouge::Symbol[:-]
    Rouge.read("+").should eq Rouge::Symbol[:+]
    Rouge.read("/").should eq Rouge::Symbol[:/]
    Rouge.read("|").should eq Rouge::Symbol[:|]
    Rouge.read(".").should eq Rouge::Symbol[:"."]
    Rouge.read(".[]").should eq Rouge::Symbol[:".[]"]
    Rouge.read("=").should eq Rouge::Symbol[:"="]
  end

  describe "keywords" do
    it "should read plain keywords" do
      Rouge.read(":loki").should eq :loki
      Rouge.read(":/").should eq :/
      Rouge.read(":wah?").should eq :wah?
      Rouge.read(":nil").should eq :nil
      Rouge.read(":true").should eq :true
      Rouge.read(":false").should eq :false
    end

    it "should read string-symbols" do
      Rouge.read(":\"!ruby!\"").should eq :"!ruby!"
    end
  end

  describe "strings" do
    it "should read plain strings" do
      Rouge.read("\"akashi yo\"").should eq "akashi yo"
      Rouge.read("\"akashi \n woah!\"").should eq "akashi \n woah!"
    end

    it "should read escape sequences" do
      Rouge.read("\"here \\\" goes\"").should eq "here \" goes"
      Rouge.read("\"here \\\\ goes\"").should eq "here \\ goes"
      Rouge.read("\"\\a\\b\\e\\f\\n\\r\"").should eq "\a\b\e\f\n\r"
      Rouge.read("\"\\s\\t\\v\"").should eq "\s\t\v"
    end
  end

  describe "lists" do
    it "should read the empty list" do
      Rouge.read("()").should eq Rouge::Cons[]
    end

    it "should read one-element lists" do
      Rouge.read("(tiffany)").should eq Rouge::Cons[Rouge::Symbol[:tiffany]]
      Rouge.read("(:raaaaash)").
          should eq Rouge::Cons[:raaaaash]
    end

    it "should read multiple-element lists" do
      Rouge.read("(1 2 3)").should eq Rouge::Cons[1, 2, 3]
      Rouge.read("(true () [] \"no\")").
          should eq Rouge::Cons[Rouge::Symbol[:true], Rouge::Cons[], [], "no"]
    end

    it "should read nested lists" do
      Rouge.read("(((3) (())) 9 ((8) (8)))").
          should eq Rouge::Cons[Rouge::Cons[Rouge::Cons[3],
          Rouge::Cons[Rouge::Cons[]]], 9,
          Rouge::Cons[Rouge::Cons[8], Rouge::Cons[8]]]
    end
  end

  describe "vectors" do
    it "should read the empty vector" do
      Rouge.read("[]").should eq []
    end

    it "should read one-element vectors" do
      Rouge.read("[tiffany]").should eq [Rouge::Symbol[:tiffany]]
      Rouge.read("[:raaaaash]").should eq [:raaaaash]
    end

    it "should read multiple-element vectors" do
      Rouge.read("[1 2 3]").should eq [1, 2, 3]
      Rouge.read("[true () [] \"no\"]").
          should eq [Rouge::Symbol[:true], Rouge::Cons[], [], "no"]
    end

    it "should read nested vectors" do
      Rouge.read("[[[3] [[]]] 9 [[8] [8]]]").
          should eq [[[3], [[]]], 9, [[8], [8]]]
    end
  end

  describe "quotations" do
    it "should read 'X as (QUOTE X)" do
      Rouge.read("'x").
          should eq Rouge::Cons[Rouge::Symbol[:quote], Rouge::Symbol[:x]]
    end

    it "should read ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
      Rouge.read("''('x)").
          should eq Rouge::Cons[Rouge::Symbol[:quote],
                    Rouge::Cons[Rouge::Symbol[:quote],
                    Rouge::Cons[Rouge::Cons[Rouge::Symbol[:quote],
                                            Rouge::Symbol[:x]]]]]
    end
  end

  describe "maps" do
    it "should read the empty map" do
      Rouge.read("{}").should eq({})
    end

    it "should read one-element maps" do
      Rouge.read("{a 1}").should eq({Rouge::Symbol[:a] => 1})
      Rouge.read("{\"quux\" [lambast]}").
          should eq({"quux" => [Rouge::Symbol[:lambast]]})
    end

    it "should read multiple-element maps" do
      Rouge.read("{:a 1 :b 2}").should eq({:a => 1, :b => 2})
      Rouge.read("{:f :f, :y :y\n:z :z}").
          should eq({:f => :f, :y => :y, :z => :z})
    end

    it "should read nested maps" do
      Rouge.read("{:a {:z 9} :b {:q q}}").should eq(
        {:a => {:z => 9}, :b => {:q => Rouge::Symbol[:q]}})
      Rouge.read("{{9 7} 5}").should eq({{9 => 7} => 5})
    end
  end

  describe "trailing-character behaviour" do
    it "should fail with trailing non-whitespace" do
      lambda {
        Rouge.read("hello joe")
      }.should raise_exception(Rouge::Reader::TrailingDataError)
    end

    it "should not fail with trailing whitespace" do
      lambda {
        Rouge.read(":hello    \n\n\t\t  ").should eq :hello
      }.should_not raise_exception
    end

    it "should deal with whitespace in strange places" do
      lambda {
        Rouge.read("[1 ]").should eq [1]
        Rouge.read(" [   2 ] ").should eq [2]
      }.should_not raise_exception
    end
  end

  describe "empty reads" do
    it "should fail on empty reads" do
      lambda {
        Rouge.read("")
      }.should raise_exception(Rouge::Reader::EndOfDataError)

      lambda {
        Rouge.read("    \n         ")
      }.should raise_exception(Rouge::Reader::EndOfDataError)
    end
  end

  describe "comments" do
    it "should ignore comments" do
      Rouge.read("42 ;what!").should eq 42
      Rouge.read("[42 ;what!\n15]").should eq [42, 15]

      lambda {
        Rouge.read(";what!")
      }.should raise_exception(Rouge::Reader::EndOfDataError)

      Rouge.read(";what!\nhmm").should eq Rouge::Symbol[:hmm]
    end
  end
end

# vim: set sw=2 et cc=80:
