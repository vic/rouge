# encoding: utf-8
require 'readline'

module Piret::REPL; end

class << Piret::REPL
  def repl(argv)
    context = self.context

    if argv.length == 1
      form = Piret.read("(do #{File.read(argv[0])})")
      Piret.eval(context, form)
      exit(0)
    elsif argv.length > 1
      STDERR.puts "!! usage: #$0 [FILE]"
      exit(1)
    end

    count = 0
    chaining = false
    while true
      if not chaining
        prompt = "#{context.ns.name}=> "
        input = Readline.readline(prompt, true)
      else
        prompt = "#{" " * [0, context.ns.name.length - 2].max}#_=> "
        input += "\n" + Readline.readline(prompt, true)
      end

      if input.nil?
        STDOUT.print "\n"
        break
      end

      begin
        form = Piret.read(input)
      rescue Piret::Reader::EndOfDataError
        chaining = true
        next
      end

      chaining = false
      begin
        result = Piret.eval(context, form)
        STDOUT.puts Piret.print(result)

        count += 1 if count < 10
        count.downto(2) do |i|
          context.set_here :"*#{i}", context[:"*#{i - 1}"]
        end
        context.set_here :"*1", result
      rescue => e
        STDOUT.puts "!! #{e.class}: #{e.message}"
        STDOUT.puts "#{e.backtrace.join "\n"}"
      end
    end
  end

  def context
    ns = Piret[:user]
    ns.refer Piret[:"piret.builtin"]
    ns.refer Piret[:ruby]
    Piret::Context.new ns
  end
end

# vim: set sw=2 et cc=80:
