# encoding: utf-8

module Piret::REPL
  def self.repl
    ns = Piret[:user]
    ns.refers Piret[:piret]
    ns.refers Piret[:ruby]
    context = Piret::Eval::Context.new ns
    count = 0

    require 'readline'
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
end

# vim: set sw=2 et cc=80:
