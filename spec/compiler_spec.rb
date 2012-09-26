# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Compiler do
  it "should fail" do
    raise "blah"
  end

  before do
    @ns = Rouge[:user]
    @compile = lambda {|rouge|
      reader = Rouge::Reader.new(@ns, rouge)
      Rouge::Compiler.compile(reader.lex, "")
    }
  end

  it "should compile numeric constants" do
    @compile.call('42').should eq '42'
  end

  it "should compile strings" do
    @compile.call('"boo\nhoo"').should eq '"boo\nhoo"'
  end

  it "should compile symbol references" do
    @compile.call('baxter').should eq 'baxter'
  end

  describe "function calls" do
    it "should compile simple function calls" do
      @compile.call('(boo)').should eq 'boo.call()'
    end

    it "should compile function calls with arguments" do
      @compile.call('(boo 1 2)').should eq 'boo.call(1, 2)'
    end

    it "should compile nested function calls" do
      @compile.call('(boo 1 (hoo 2))').should eq 'boo.call(1, hoo.call(2))'
    end
  end
end

# vim: set sw=2 et cc=80:
