# encoding: utf-8

module Piret
  require 'piret/core'
  require 'piret/reader'
  require 'piret/printer'
  require 'piret/eval'

  def self.read(input)
    Piret::Reader.read input
  end

  def self.eval(context, *forms)
    Piret::Eval.eval context, *forms
  end

  def self.print(form)
    Piret::Printer.print form
  end
end

# vim: set sw=2 et cc=80:
