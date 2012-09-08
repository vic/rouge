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



  p input
end

# vim: set sw=2 et cc=80:
