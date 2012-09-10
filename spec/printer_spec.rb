# encoding: utf-8
require 'spec_helper'
require 'rl'

describe RL::Printer do
  describe "the print method" do
    it "should print numbers" do
      RL.print(12755).should eq "12755"
    end

    it "should print symbols" do
      RL.print(:loki).should eq "loki"
      RL.print(:/).should eq "/"
      RL.print(:wah?).should eq "wah?"
      RL.print(:"!ruby!").should eq "!ruby!"
      RL.print(:nil).should eq "nil"
      RL.print(:true).should eq "true"
      RL.print(:false).should eq "false"
    end

    describe "keywords" do
      it "should print plain keywords" do
        RL.print(RL::Keyword[:loki]).should eq ":loki"
        RL.print(RL::Keyword[:/]).should eq ":/"
        RL.print(RL::Keyword[:wah?]).should eq ":wah?"
        RL.print(RL::Keyword[:nil]).should eq ":nil"
        RL.print(RL::Keyword[:true]).should eq ":true"
        RL.print(RL::Keyword[:false]).should eq ":false"
      end

      it "should print string-symbols" do
        RL.print(RL::Keyword[:"!ruby!"]).should eq ":\"!ruby!\""
      end
    end

    describe "strings" do
      it "should print plain strings" do
        RL.print("akashi yo").should eq "\"akashi yo\""
        RL.print("akashi \n woah!").should eq "\"akashi \\n woah!\""
      end

      it "should print escape sequences" do
        RL.print("here \" goes").should eq "\"here \\\" goes\"" 
        RL.print("here \\ goes").should eq "\"here \\\\ goes\""
        RL.print("\a\b\e\f\n").should eq "\"\\a\\b\\e\\f\\n\""
        RL.print("\r\t\v").should eq "\"\\r\\t\\v\""
      end
    end

    describe "lists" do
      it "should print the empty list" do
        RL.print([]).should eq "()"
      end

      it "should print one-element lists" do
        RL.print([:tiffany]).should eq "(tiffany)"
        RL.print([RL::Keyword[:raaaaash]]).should eq "(:raaaaash)"
      end

      it "should print multiple-element lists" do
        RL.print([1, 2, 3]).should eq "(1 2 3)"
        RL.print([:true, [], "no"]).should eq "(true () \"no\")"
      end

      it "should print nested lists" do
        RL.print([[[3], [[]]], 9, [[8], [8]]]).should eq \
            "(((3) (())) 9 ((8) (8)))"
      end
    end

    describe "quotations" do
      it "should print 'X as (QUOTE X)" do
        RL.print([:quote, :x]).should eq "'x"
      end

      it "should print ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
        RL.print([:quote, [:quote, [[:quote, :x]]]]).should eq "''('x)"
      end
    end

    describe "maps" do
      it "should print the empty map" do
        RL.print({}).should eq "{}"
      end

      it "should print one-element maps" do
        RL.print({:a => 1}).should eq "{a 1}"
        RL.print({"quux" => [:lambast]}).should eq "{\"quux\" (lambast)}"
      end

      it "should print multiple-element maps" do
        # XXX(arlen): these tests rely on stable-ish Hash order
        RL.print({:a => 1, :b => 2}).should eq "{a 1, b 2}"
        RL.print({:f => :f, :y => :y, :z => :z}).should eq "{f f, y y, z z}"
      end

      it "should print nested maps" do
        # XXX(arlen): this test relies on stable-ish Hash order
        RL.print({:a => {:z => 9}, :b => {:q => RL::Keyword[:q]}}).should eq \
            "{a {z 9}, b {q :q}}"
        RL.print({{9 => 7} => 5}).should eq "{{9 7} 5}"
      end
    end

    it "should print the fundamental objects" do
      RL.print(nil).should eq "nil"
      RL.print(true).should eq "true"
      RL.print(false).should eq "false"
    end

    it "should print Ruby classes in their namespace" do
      RL.print(Object).should eq "r/Object"
      RL.print(Class).should eq "r/Class"
      RL.print(RL::Eval).should eq "r/RL.Eval"
      anon = Class.new
      RL.print(anon).should eq anon.inspect
    end

    describe "unknown form behaviour" do
      it "should print the Ruby inspection of unknown forms" do
        l = lambda {}
        RL.print(l).should eq l.inspect
      end
    end
  end
end

# vim: set sw=2 et cc=80:
