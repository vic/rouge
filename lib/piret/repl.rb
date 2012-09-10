# encoding: utf-8

module Piret::REPL
  def self.repl
    ns = Piret[:user]
    ns.refers Piret[:piret]
    ns.refers Piret[:ruby]
    context = Piret::Eval::Context.new ns
    count = 0

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
