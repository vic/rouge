# encoding: utf-8

$: << "./lib"

require 'rl'

context = RL::Eval::Context.toplevel

while true
  STDOUT.print "rl=> "
  STDOUT.flush

  begin
    input = STDIN.readline
  rescue EOFError
    STDOUT.print "\n"
    break
  end

  begin
    form = RL.read(input)
    result = RL.eval(context, form)
    STDOUT.puts RL.print(result)
  rescue => e
    STDOUT.puts "!! #{e.class}: #{e.message}"
    STDOUT.puts "#{e.backtrace.join "\n"}"
  end
end

# vim: set sw=2 et cc=80:
