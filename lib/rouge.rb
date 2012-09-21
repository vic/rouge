# encoding: utf-8

module Rouge; end

class << Rouge
  require 'rouge/wrappers'
  require 'rouge/reader'
  require 'rouge/printer'
  require 'rouge/eval'
  require 'rouge/repl'

  #   This top-level eval post-processes the backtrace.  Accordingly, it
  # should only be called by consumers, and never by Rouge internally itself,
  # lest it catches an exception and processes the backtrace too early.
  #   Use Rouge::Context#eval internally.
  def eval(context, *forms)
    Rouge::Eval.eval context, *forms
  rescue Exception => e
    # Remove Rouge-related lines unless the exception originated in Rouge.
    e.backtrace.map! {|line|
      line.scan(File.dirname(__FILE__)).length > 0 ? nil : line
    }.compact! unless e.backtrace[0].scan(File.dirname(__FILE__)).length > 0
    raise e
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

    form = "[#{File.read(Rouge.relative_to_lib('boot.rg'))}\n]"
    boot = user.read(form)
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
