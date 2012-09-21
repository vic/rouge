# encoding: utf-8
require 'spec_helper'
require 'rouge'
require 'term/ansicolor'

describe Rouge do
  before do
    Rouge.boot!
  end

  describe "the eval method" do
    it "should eval forms in this context, post-processing the backtrace" do
      context = Rouge::Context.new Rouge[:user]
      form = Rouge.read <<-ROUGE
        (do
          (defn z [] (throw (RuntimeError. "boo")))
          (defn y [] (z))
          (defn x [] (y))
          (x))
      ROUGE

      ex = nil
      begin
        Rouge.eval context, form
      rescue => e
        ex = e
      end

      ex.should_not be_nil
      ex.backtrace[0..3].
          should eq ["(rouge):?:rouge.builtin/throw",
                     "(rouge):?:user/z",
                     "(rouge):?:user/y",
                     "(rouge):?:user/x"]
    end
  end

  describe "the rouge.core namespace" do
    before do
      @ns = Rouge[:"rouge.core"]
    end

    it "should contain the defn macro" do
      lambda {
        @ns[:defn].should be_an_instance_of Rouge::Macro
      }.should_not raise_exception(Rouge::Eval::BindingNotFoundError)
    end
  end

  describe "the user namespace" do
    before do
      @ns = Rouge[:user]
    end

    it "should refer rouge.builtin, rouge.core and ruby" do
      @ns.refers.should include(Rouge[:"rouge.builtin"])
      @ns.refers.should include(Rouge[:"rouge.core"])
      @ns.refers.should include(Rouge[:"ruby"])
    end
  end

  describe "the Rouge specs" do
    Dir[relative_to_spec("*.rg")].each do |file|
      it "should pass #{File.basename file}" do
        r = Rouge.eval(Rouge::Context.new(Rouge[:user]),
                       *Rouge.read("[#{File.read(file)}]"))
        total = r[:passed] + r[:failed].length

        message = 
            "#{total} example#{total == 1 ? "" : "s"}, " +
            "#{r[:failed].length} failure#{r[:failed].length == 1 ? "" : "s"}"

        if r[:failed].length > 0
          STDOUT.puts Term::ANSIColor.red(message)
          raise RuntimeError,
              "#{r[:failed].length} failed " +
              "case#{r[:failed].length == 1 ? "" : "s"} in #{file}:\n" +
              r[:failed].map {|e| "  - #{e.join(" -> ")}"}.join("\n")
        else
          STDOUT.puts Term::ANSIColor.green(message)
        end
      end
    end
  end
end

# vim: set sw=2 et cc=80:
