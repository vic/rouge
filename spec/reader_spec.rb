# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Reader do
  before do
    @ns = Rouge[:"user.spec"]
  end

  describe "reading numbers" do
    it "should read plain numbers" do
      @ns.read("12755").should eq 12755
    end

    it "should read separated numbers" do
      @ns.read("2_50_9").should eq 2509
    end
  end

  it "should read symbols" do
    @ns.read("loki").should eq Rouge::Symbol[:loki]
    @ns.read("wah?").should eq Rouge::Symbol[:wah?]
    @ns.read("!ruby!").should eq Rouge::Symbol[:"!ruby!"]
    @ns.read("nil").should eq Rouge::Symbol[:nil]
    @ns.read("nil").should eq nil
    @ns.read("true").should eq Rouge::Symbol[:true]
    @ns.read("true").should eq true
    @ns.read("false").should eq Rouge::Symbol[:false]
    @ns.read("false").should eq false
    @ns.read("&").should eq Rouge::Symbol[:&]
    @ns.read("*").should eq Rouge::Symbol[:*]
    @ns.read("-").should eq Rouge::Symbol[:-]
    @ns.read("+").should eq Rouge::Symbol[:+]
    @ns.read("/").should eq Rouge::Symbol[:/]
    @ns.read("|").should eq Rouge::Symbol[:|]
    @ns.read("$").should eq Rouge::Symbol[:"$"]
    @ns.read(".").should eq Rouge::Symbol[:"."]
    @ns.read(".[]").should eq Rouge::Symbol[:".[]"]
    @ns.read("=").should eq Rouge::Symbol[:"="]
    @ns.read("%").should eq Rouge::Symbol[:"%"]
    @ns.read(">").should eq Rouge::Symbol[:">"]
    @ns.read("<").should eq Rouge::Symbol[:"<"]
    @ns.read("%50").should eq Rouge::Symbol[:"%50"]
    @ns.read("xyz#").should eq Rouge::Symbol[:"xyz#"]
  end

  describe "keywords" do
    it "should read plain keywords" do
      @ns.read(":loki").should eq :loki
      @ns.read(":/").should eq :/
      @ns.read(":wah?").should eq :wah?
      @ns.read(":nil").should eq :nil
      @ns.read(":true").should eq :true
      @ns.read(":false").should eq :false
    end

    it "should read string-symbols" do
      @ns.read(":\"!ruby!\"").should eq :"!ruby!"
    end
  end

  describe "strings" do
    it "should read plain strings" do
      @ns.read("\"akashi yo\"").should eq "akashi yo"
      @ns.read("\"akashi \n woah!\"").should eq "akashi \n woah!"
    end

    it "should read escape sequences" do
      @ns.read("\"here \\\" goes\"").should eq "here \" goes"
      @ns.read("\"here \\\\ goes\"").should eq "here \\ goes"
      @ns.read("\"\\a\\b\\e\\f\\n\\r\"").should eq "\a\b\e\f\n\r"
      @ns.read("\"\\s\\t\\v\"").should eq "\s\t\v"
    end

    it "should read strings as frozen" do
      @ns.read("\"bah\"").should be_frozen
    end
  end

  describe "lists" do
    it "should read the empty list" do
      @ns.read("()").should eq Rouge::Cons[]
    end

    it "should read one-element lists" do
      @ns.read("(tiffany)").should eq Rouge::Cons[Rouge::Symbol[:tiffany]]
      @ns.read("(:raaaaash)").
          should eq Rouge::Cons[:raaaaash]
    end

    it "should read multiple-element lists" do
      @ns.read("(1 2 3)").should eq Rouge::Cons[1, 2, 3]
      @ns.read("(true () [] \"no\")").
          should eq Rouge::Cons[Rouge::Symbol[:true], Rouge::Cons[], [], "no"]
    end

    it "should read nested lists" do
      @ns.read("(((3) (())) 9 ((8) (8)))").
          should eq Rouge::Cons[Rouge::Cons[Rouge::Cons[3],
          Rouge::Cons[Rouge::Cons[]]], 9,
          Rouge::Cons[Rouge::Cons[8], Rouge::Cons[8]]]
    end
    
    it "should read lists as frozen" do
      @ns.read("()").should be_frozen
      @ns.read("(1)").should be_frozen
      @ns.read("(1 2)").should be_frozen
    end
  end

  describe "vectors" do
    it "should read the empty vector" do
      @ns.read("[]").should eq []
    end

    it "should read one-element vectors" do
      @ns.read("[tiffany]").should eq [Rouge::Symbol[:tiffany]]
      @ns.read("[:raaaaash]").should eq [:raaaaash]
    end

    it "should read multiple-element vectors" do
      @ns.read("[1 2 3]").should eq [1, 2, 3]
      @ns.read("[true () [] \"no\"]").
          should eq [Rouge::Symbol[:true], Rouge::Cons[], [], "no"]
    end

    it "should read nested vectors" do
      @ns.read("[[[3] [[]]] 9 [[8] [8]]]").
          should eq [[[3], [[]]], 9, [[8], [8]]]
    end

    it "should read vectors as frozen" do
      @ns.read("[]").should be_frozen
      @ns.read("[1]").should be_frozen
      @ns.read("[1 2]").should be_frozen
    end
  end

  describe "quotations" do
    it "should read 'X as (QUOTE X)" do
      @ns.read("'x").
          should eq Rouge::Cons[Rouge::Symbol[:quote], Rouge::Symbol[:x]]
    end

    it "should read ''('X) as (QUOTE (QUOTE ((QUOTE X))))" do
      @ns.read("''('x)").
          should eq Rouge::Cons[Rouge::Symbol[:quote],
                    Rouge::Cons[Rouge::Symbol[:quote],
                    Rouge::Cons[Rouge::Cons[Rouge::Symbol[:quote],
                                            Rouge::Symbol[:x]]]]]
    end
  end

  describe "vars" do
    it "should read #'X as (VAR X)" do
      @ns.read("#'x").
          should eq Rouge::Cons[Rouge::Symbol[:var], Rouge::Symbol[:x]]
    end

    it "should read #'#'(#'X) as (VAR (VAR ((VAR X))))" do
      @ns.read("#'#'(#'x)").
          should eq Rouge::Cons[Rouge::Symbol[:var],
                    Rouge::Cons[Rouge::Symbol[:var],
                    Rouge::Cons[Rouge::Cons[Rouge::Symbol[:var],
                                            Rouge::Symbol[:x]]]]]
    end
  end

  describe "maps" do
    it "should read the empty map" do
      @ns.read("{}").should eq({})
    end

    it "should read one-element maps" do
      @ns.read("{a 1}").to_s.should eq({Rouge::Symbol[:a] => 1}.to_s)
      @ns.read("{\"quux\" [lambast]}").
          should eq({"quux" => [Rouge::Symbol[:lambast]]})
    end

    it "should read multiple-element maps" do
      @ns.read("{:a 1 :b 2}").should eq({:a => 1, :b => 2})
      @ns.read("{:f :f, :y :y\n:z :z}").
          should eq({:f => :f, :y => :y, :z => :z})
    end

    it "should read nested maps" do
      @ns.read("{:a {:z 9} :b {:q q}}").should eq(
        {:a => {:z => 9}, :b => {:q => Rouge::Symbol[:q]}})
      @ns.read("{{9 7} 5}").should eq({{9 => 7} => 5})
    end

    it "should read maps as nested" do
      @ns.read("{}").should be_frozen
      @ns.read("{:a 1}").should be_frozen
    end
  end

  describe "trailing-character behaviour" do
    it "should fail with trailing non-whitespace" do
      lambda {
        @ns.read("hello joe")
      }.should raise_exception(Rouge::Reader::TrailingDataError)
    end

    it "should not fail with trailing whitespace" do
      lambda {
        @ns.read(":hello    \n\n\t\t  ").should eq :hello
      }.should_not raise_exception
    end

    it "should deal with whitespace in strange places" do
      lambda {
        @ns.read("[1 ]").should eq [1]
        @ns.read(" [   2 ] ").should eq [2]
      }.should_not raise_exception
    end
  end

  describe "empty reads" do
    it "should fail on empty reads" do
      lambda {
        @ns.read("")
      }.should raise_exception(Rouge::Reader::EndOfDataError)

      lambda {
        @ns.read("    \n         ")
      }.should raise_exception(Rouge::Reader::EndOfDataError)
    end
  end

  describe "comments" do
    it "should ignore comments" do
      @ns.read("42 ;what!").should eq 42
      @ns.read("[42 ;what!\n15]").should eq [42, 15]

      lambda {
        @ns.read(";what!")
      }.should raise_exception(Rouge::Reader::EndOfDataError)

      @ns.read(";what!\nhmm").should eq Rouge::Symbol[:hmm]
    end
  end

  describe "backquoting" do
    describe "non-cons lists" do
      it "should quote non-cons lists" do
        @ns.read('`3').should eq @ns.read("'3")
        @ns.read('`"my my my"').should eq @ns.read(%{'"my my my"})
      end

      it "should dequote within non-cons lists" do
        @ns.read('`~3').should eq @ns.read("3")
        @ns.read('``~3').should eq @ns.read("'3")
        @ns.read('``~~3').should eq @ns.read("3")
      end
    end

    describe "cons-lists" do
      it "should quote cons lists" do
        @ns.read('`(1 2)').should eq @ns.read("(list '1 '2)")
        @ns.read('`(a b)').
            should eq @ns.read("(list 'user.spec/a 'user.spec/b)")
      end

      it "should dequote within cons lists" do
        @ns.read('`(a ~b)').should eq @ns.read("(list 'user.spec/a b)")
        @ns.read('`(a ~(b `(c ~d)))').
            should eq @ns.read("(list 'user.spec/a (b (list 'user.spec/c d)))")
        @ns.read('`(a `(b ~c))').
            should eq @ns.read("(list 'user.spec/a (list 'list " \
                               "(list 'quote 'user.spec/b) 'user.spec/c))")
        @ns.read('`~`(x)').should eq @ns.read("(list 'x)")
      end

      it "should dequote within maps" do
        @ns.read('`{a ~b}').to_s.should eq @ns.read("{'user.spec/a b}").to_s
      end

      it "should splice within seqs and vectors" do
        @ns.read('`(a ~@b c)').
            should eq @ns.read("(seq (concat (list 'user.spec/a) b " \
                               "(list 'user.spec/c)))")
        @ns.read('`(~@(a b) ~c)').
            should eq @ns.read("(seq (concat (a b) (list c)))")
        @ns.read('`[a ~@b c]').should eq @ns.read(<<-ROUGE)
            (apply vector (concat (list 'user.spec/a) b (list 'user.spec/c)))
        ROUGE
        @ns.read('`[~@(a b) ~c]').
            should eq @ns.read("(apply vector (concat (a b) (list c)))")
      end
    end
  end

  describe "anonymous functions" do
    it "should read anonymous functions" do
      @ns.read('#(1)').should eq @ns.read('(fn [] (1))')
      @ns.read('#(do 1)').should eq @ns.read('(fn [] (do 1))')
      @ns.read('#(%)').should eq @ns.read('(fn [%1] (%1))')
      @ns.read('#(%2)').should eq @ns.read('(fn [%1 %2] (%2))')
      @ns.read('#(%5)').should eq @ns.read('(fn [%1 %2 %3 %4 %5] (%5))')
      @ns.read('#(%2 %)').should eq @ns.read('(fn [%1 %2] (%2 %1))')
    end
  end

  describe "metadata" do
    it "should read metadata" do
      y = @ns.read('^{:x 1} y')
      y.should eq Rouge::Symbol[:y]
      y.meta.to_s.should eq({:x => 1}.to_s)
    end

    it "should stack metadata" do
      y = @ns.read('^{:y 2} ^{:y 3 :z 2} y')
      y.should eq Rouge::Symbol[:y]
      y.meta.should include({:y => 2, :z => 2})
    end

    it "should assign tags" do
      y = @ns.read('^"xyz" y')
      y.should eq Rouge::Symbol[:y]
      y.meta.should include({:tag => "xyz"})
    end

    it "should assign symbol markers" do
      y = @ns.read('^:blargh y')
      y.should eq Rouge::Symbol[:y]
      y.meta.should include({:blargh => true})
    end
  end

  describe "deref" do
    it "should read derefs" do
      @ns.read('@(boo)').should eq @ns.read('(rouge.core/deref (boo))')
    end
  end
end

# vim: set sw=2 et cc=80:
