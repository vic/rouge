# encoding: utf-8
require 'spec_helper'
require 'rouge'

describe Rouge::Compiler do
  before do
    @ns = Rouge[:"user.spec"]
    @ns.refer Rouge[:"rouge.builtin"]

    @read = lambda do |input|
      Rouge::Reader.new(@ns, input).lex
    end

    @compile = lambda do |input|
      form = @read.call(input)
      Rouge::Compiler.compile(@ns, Set.new, form)
    end
  end

=begin
  it "should compile with respect to locals" do
    lambda {
      @compile.call("(fn [] a)")
    }.should raise_exception(Rouge::Namespace::VarNotFoundError)

    lambda {
      @compile.call("q")
    }.should raise_exception(Rouge::Namespace::VarNotFoundError)

    lambda {
      @compile.call("(let [x 8] x)")
    }.should_not raise_exception

    lambda {
      @compile.call("(let [x 8] y)")
    }.should raise_exception(Rouge::Namespace::VarNotFoundError)
  end
=end

  it "should execute macro calls when compiling" do
    @ns.set_here :thingy, Rouge::Macro[lambda {|f|
      Rouge::Cons[Rouge::Symbol[:list], *f.to_a]
    }]
    @compile.call("(let [list 'thing] (thingy (1 2 3)))").
        should eq @read.call("(let [list 'thing] (list 1 2 3))")
  end

  # TODO: recursive compilation of macro calls? or sth.
end

# vim: set sw=2 et cc=80:
