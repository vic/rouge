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
    Piret::Eval::Namespace[ns]
  end

  def repl(argv)
    Piret::REPL.repl(argv)
  end
end

# vim: set sw=2 et cc=80:
