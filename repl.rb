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

  form = RL.read(input)
  result = RL.eval(context, form)
  STDOUT.puts RL.print(result)
end

# vim: set sw=2 et cc=80:
