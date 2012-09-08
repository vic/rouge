# encoding: utf-8

$: << "./lib"

require 'rl'

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
  STDOUT.puts "read: #{RL.print form}   == #{form}"
  result = RL.eval(form)
  STDOUT.puts "eval: #{RL.print result}   == #{result}"
end

# vim: set sw=2 et cc=80:
