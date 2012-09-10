# encoding: utf-8

module Piret
  require 'piret/core'
  require 'piret/reader'
  require 'piret/printer'
  require 'piret/eval'
end

class << Piret
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

  def repl
    ns = Piret[:user]
    ns.refers Piret[:piret]
    ns.refers Piret[:ruby]
    context = Piret::Eval::Context.new ns

    require 'readline'
    while true
      input = Readline.readline("#{context.ns.name}=> ", true)
      if input.nil?
        STDOUT.print "\n"
        break
      end

      begin
        form = Piret.read(input)
        result = Piret.eval(context, form)
        STDOUT.puts Piret.print(result)
      rescue => e
        STDOUT.puts "!! #{e.class}: #{e.message}"
        STDOUT.puts "#{e.backtrace.join "\n"}"
      end
    end
  end
end

# vim: set sw=2 et cc=80:
