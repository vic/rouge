# encoding: utf-8
require 'spec_helper'
require 'printer'

describe Printer do
  describe "the print method" do
    it "should print numbers" do
      Printer.print(12755).should eq "12755"
    end

    it "should print symbols" do
      Printer.print(:loki).should eq "loki"
      Printer.print(:/).should eq "/"
      Printer.print(:wah?).should eq "wah?"
      Printer.print(:"!ruby!").should eq "!ruby!"
      Printer.print(:nil).should eq "nil"
      Printer.print(:true).should eq "true"
      Printer.print(:false).should eq "false"
    end

    describe "keywords" do
      it "should print plain keywords" do
        Printer.print(Keyword[:loki]).should eq ":loki"
        Printer.print(Keyword[:/]).should eq ":/"
        Printer.print(Keyword[:wah?]).should eq ":wah?"
        Printer.print(Keyword[:nil]).should eq ":nil"
        Printer.print(Keyword[:true]).should eq ":true"
        Printer.print(Keyword[:false]).should eq ":false"
      end

      it "should print string-symbols" do
        Printer.print(Keyword[:"!ruby!"]).should eq ":\"!ruby!\""
      end
    end

    describe "strings" do
      it "should print plain strings" do
        Printer.print("akashi yo").should eq "\"akashi yo\""
        Printer.print("akashi \n woah!").should eq "\"akashi \\n woah!\""
      end

      it "should print escape sequences" do
        Printer.print("here \" goes").should eq "\"here \\\" goes\"" 
        Printer.print("here \\ goes").should eq "\"here \\\\ goes\""
        Printer.print("\a\b\e\f\n").should eq "\"\\a\\b\\e\\f\\n\""
        Printer.print("\r\t\v").should eq "\"\\r\\t\\v\""
      end
    end

    describe "lists" do
      it "should print the empty list" do
        Printer.print([]).should eq "()"
      end

      it "should print one-element lists" do
        Printer.print([:tiffany]).should eq "(tiffany)"
        Printer.print([Keyword[:raaaaash]]).should eq "(:raaaaash)"
      end

      it "should print multiple-element lists" do
        Printer.print([1, 2, 3]).should eq "(1 2 3)"
        Printer.print([:true, [], "no"]).should eq "(true () \"no\")"
      end

      it "should print nested lists" do
        Printer.print([[[3], [[]]], 9, [[8], [8]]]).should eq \
          "(((3) (())) 9 ((8) (8)))"
      end
    end

    describe "quotations" do
      it "should print 'X as (QUOTE X)" do
        Printer.print([:quote, :x]).should eq "'x"
      end

      it "should print ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
        Printer.print([:quote, [:quote, [[:quote, :x]]]]).should eq "''('x)"
      end
    end

    describe "maps" do
      it "should print the empty map" do
        Printer.print({}).should eq "{}"
      end

      it "should print one-element maps" do
        Printer.print({:a => 1}).should eq "{a 1}"
        Printer.print({"quux" => [:lambast]}).should eq "{\"quux\" (lambast)}"
      end

      it "should print multiple-element maps" do
        # XXX(arlen): these tests rely on stable-ish Hash order
        Printer.print({:a => 1, :b => 2}).should eq "{a 1, b 2}"
        Printer.print({:f => :f, :y => :y, :z => :z}).should eq \
          "{f f, y y, z z}"
      end

      it "should print nested maps" do
        # XXX(arlen): this test relies on stable-ish Hash order
        Printer.print({:a => {:z => 9}, :b => {:q => Keyword[:q]}}).should eq \
          "{a {z 9}, b {q :q}}"
        Printer.print({{9 => 7} => 5}).should eq \
          "{{9 7} 5}"
      end
    end
  end
end

# vim: set sw=2 et cc=80:
