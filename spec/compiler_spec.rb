# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Compiler do
  before do
    ns = Rouge[:user]
    ns.refer Rouge[:"rouge.builtin"]

    @compile = lambda do |input|
      form = Rouge::Reader.new(ns, input).lex
      Rouge::Compiler.compile(ns, Set.new, form)
    end
  end

  it "should compile with respect to locals" do
    lambda {
      @compile.call("(fn [] a)")
    }.should raise_exception(Rouge::Compiler::Error)

    lambda {
      @compile.call("q")
    }.should raise_exception(Rouge::Compiler::Error)

    lambda {
      @compile.call("(let [x 8] x)")
    }.should_not raise_exception

    lambda {
      @compile.call("(let [x 8] y)")
    }.should raise_exception(Rouge::Compiler::Error)
  end
end

# vim: set sw=2 et cc=80:
