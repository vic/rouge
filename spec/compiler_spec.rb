# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Compiler do
  it "should fail" do
    raise "blah"
  end

  before do
    ns = Rouge[:user]

    @compile = lambda do |input|
      form = Rouge::Reader.new(ns, input).lex
      Rouge::Compiler.compile(ns, Set.new, form)
    end
  end

  it "xyz" do
    lambda {
      @compile.call("(fn [] a)")
    }.should raise_exception

    lambda {
      @compile.call("q")
    }.should raise_exception

    lambda {
      @compile.call("(let [x 8] x)")
    }.should_not raise_exception

    lambda {
      @compile.call("(let [x 8] y)")
    }.should raise_exception
  end
end

# vim: set sw=2 et cc=80:
