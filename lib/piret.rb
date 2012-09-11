# encoding: utf-8

module Piret; end

class << Piret
  require 'piret/core'
  require 'piret/reader'
  require 'piret/printer'
  require 'piret/eval'
  require 'piret/repl'

  def read(input)
    Piret::Reader.read input
  end

  def eval(context, *forms)
    Piret::Eval.eval context, *forms
  end

  def print(form)
    Piret::Printer.print form
  end

  def [](ns)
    Piret::Namespace[ns]
  end

  def boot!
    core = Piret[:"piret.core"]
    core.refer Piret[:"piret.builtin"]

    user = Piret[:user]
    user.refer Piret[:"piret.builtin"]
    user.refer Piret[:"piret.core"]
    user.refer Piret[:ruby]

    boot = Piret.read("[#{File.read(Piret.relative_to_lib('../piret/boot.p'))}]")
    Piret.eval(Piret::Context.new(user), *boot)
  end

  def repl(argv)
    boot!
    Piret::REPL.repl(argv)
  end

  def relative_to_lib name
    File.join(File.dirname(File.absolute_path(__FILE__)), name)
  end
end

# vim: set sw=2 et cc=80:
