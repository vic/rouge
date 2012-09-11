# encoding: utf-8
require 'spec_helper'
require 'piret'

describe Piret::Printer do
  describe "the print method" do
    it "should print numbers" do
      Piret.print(12755).should eq "12755"
    end

    it "should print symbols" do
      Piret.print(Piret::Symbol[:loki]).should eq "loki"
      Piret.print(Piret::Symbol[:/]).should eq "/"
      Piret.print(Piret::Symbol[:wah?]).should eq "wah?"
      Piret.print(Piret::Symbol[:"!ruby!"]).should eq "!ruby!"
      Piret.print(Piret::Symbol[:nil]).should eq "nil"
      Piret.print(Piret::Symbol[:true]).should eq "true"
      Piret.print(Piret::Symbol[:false]).should eq "false"
    end

    describe "keywords" do
      it "should print plain keywords" do
        Piret.print(:loki).should eq ":loki"
        Piret.print(:/).should eq ":/"
        Piret.print(:wah?).should eq ":wah?"
        Piret.print(:nil).should eq ":nil"
        Piret.print(:true).should eq ":true"
        Piret.print(:false).should eq ":false"
      end

      it "should print string-symbols" do
        Piret.print(:"!ruby!").should eq ":\"!ruby!\""
      end
    end

    describe "strings" do
      it "should print plain strings" do
        Piret.print("akashi yo").should eq "\"akashi yo\""
        Piret.print("akashi \n woah!").should eq "\"akashi \\n woah!\""
      end

      it "should print escape sequences" do
        Piret.print("here \" goes").should eq "\"here \\\" goes\"" 
        Piret.print("here \\ goes").should eq "\"here \\\\ goes\""
        Piret.print("\a\b\e\f\n").should eq "\"\\a\\b\\e\\f\\n\""
        Piret.print("\r\t\v").should eq "\"\\r\\t\\v\""
      end
    end

    describe "lists" do
      it "should print the empty list" do
        Piret.print(Piret::Cons[]).should eq "()"
      end

      it "should print one-element lists" do
        Piret.print(Piret::Cons[:tiffany]).should eq "(tiffany)"
        Piret.print(Piret::Cons[Piret::Keyword[:raaaaash]]).
            should eq "(:raaaaash)"
      end

      it "should print multiple-element lists" do
        Piret.print(Piret::Cons[1, 2, 3]).should eq "(1 2 3)"
        Piret.print(Piret::Cons[:true, Piret::Cons[], [], "no"]).
            should eq "(true () [] \"no\")"
      end

      it "should print nested lists" do
        Piret.print(Piret::Cons[Piret::Cons[Piret::Cons[3], 
                    Piret::Cons[Piret::Cons[]]], 9,
                    Piret::Cons[Piret::Cons[8], Piret::Cons[8]]]).
            should eq "(((3) (())) 9 ((8) (8)))"
      end
    end

    describe "vectors" do
      it "should print the empty vector" do
        Piret.print([]).should eq "[]"
      end

      it "should print one-element vectors" do
        Piret.print([Piret::Symbol[:tiffany]]).should eq "[tiffany]"
        Piret.print([:raaaaash]).should eq "[:raaaaash]"
      end

      it "should print multiple-element vectors" do
        Piret.print([1, 2, 3]).should eq "[1 2 3]"
        Piret.print([Piret::Symbol[:true], Piret::Cons[], [], "no"]).
            should eq "[true () [] \"no\"]"
      end

      it "should print nested vectors" do
        Piret.print([[[3], [[]]], 9, [[8], [8]]]).
            should eq "[[[3] [[]]] 9 [[8] [8]]]"
      end
    end

    describe "quotations" do
      it "should print 'X as (QUOTE X)" do
        Piret.print(Piret::Cons[Piret::Symbol[:quote], Piret::Symbol[:x]]).
            should eq "'x"
      end

      it "should print ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
        Piret.print(Piret::Cons[Piret::Symbol[:quote],
                    Piret::Cons[Piret::Symbol[:quote],
                    Piret::Cons[Piret::Cons[Piret::Symbol[:quote],
                    Piret::Symbol[:x]]]]]).
            should eq "''('x)"
      end
    end

    describe "maps" do
      it "should print the empty map" do
        Piret.print({}).should eq "{}"
      end

      it "should print one-element maps" do
        Piret.print({Piret::Symbol[:a] => 1}).should eq "{a 1}"
        Piret.print({"quux" => [Piret::Symbol[:lambast]]}).
            should eq "{\"quux\" [lambast]}"
      end

      it "should print multiple-element maps" do
        # XXX(arlen): these tests rely on stable-ish Hash order
        Piret.print({:a => 1, :b => 2}).should eq "{:a 1, :b 2}"
        Piret.print({:f => :f, :y => :y, :z => :z}).
            should eq "{:f :f, :y :y, :z :z}"
      end

      it "should print nested maps" do
        # XXX(arlen): this test relies on stable-ish Hash order
        Piret.print({:a => {:z => 9},
                    :b => {:q => Piret::Symbol[:q]}}).
            should eq "{:a {:z 9}, :b {:q q}}"
        Piret.print({{9 => 7} => 5}).should eq "{{9 7} 5}"
      end
    end

    it "should print the fundamental objects" do
      Piret.print(nil).should eq "nil"
      Piret.print(true).should eq "true"
      Piret.print(false).should eq "false"
    end

    it "should print Ruby classes in their namespace" do
      Piret.print(Object).should eq "ruby/Object"
      Piret.print(Class).should eq "ruby/Class"
      Piret.print(Piret::Eval).should eq "ruby/Piret.Eval"
      anon = Class.new
      Piret.print(anon).should eq anon.inspect
    end

    it "should print builtin forms in their namespace" do
      Piret.print(Piret::Builtin[Piret::Eval::Builtins.method(:let)]).
          should eq "piret/let"
      Piret.print(Piret::Builtin[Piret::Eval::Builtins.method(:def)]).
          should eq "piret/def"
    end

    describe "unknown form behaviour" do
      it "should print the Ruby inspection of unknown forms" do
        l = lambda {}
        Piret.print(l).should eq l.inspect
      end
    end
  end
end

# vim: set sw=2 et cc=80:
