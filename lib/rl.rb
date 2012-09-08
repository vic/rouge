# encoding: utf-8

module RL; end

require 'rl/core'
require 'rl/reader'
require 'rl/printer'
require 'rl/eval'

class << RL
  def read(input)
    RL::Reader.read input
  end

  def eval(form)
    RL::Eval.eval form
  end

  def print(form)
    RL::Printer.print form
  end
end

# vim: set sw=2 et cc=80:
