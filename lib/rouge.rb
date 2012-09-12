# encoding: utf-8

module Rouge; end

class << Rouge
  require 'rouge/core'
  require 'rouge/reader'
  require 'rouge/printer'
  require 'rouge/eval'
  require 'rouge/repl'

  def read(input)
    Rouge::Reader.read input
  end

  def eval(context, *forms)
    Rouge::Eval.eval context, *forms
  end

  def print(form)
    Rouge::Printer.print form
  end

  def [](ns)
    Rouge::Namespace[ns]
  end

  def boot!
    core = Rouge[:"rouge.core"]
    core.refer Rouge[:"rouge.builtin"]

    user = Rouge[:user]
    user.refer Rouge[:"rouge.builtin"]
    user.refer Rouge[:"rouge.core"]
    user.refer Rouge[:ruby]

    form = "[#{File.read(Rouge.relative_to_lib('../rouge/boot.rg'))}\n]"
    boot = Rouge.read(form)
    Rouge.eval(Rouge::Context.new(user), *boot)
  end

  def repl(argv)
    boot!
    Rouge::REPL.repl(argv)
  end

  def relative_to_lib name
    File.join(File.dirname(File.absolute_path(__FILE__)), name)
  end
end

# vim: set sw=2 et cc=80:
