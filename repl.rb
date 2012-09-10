# encoding: utf-8

$: << "./lib"

require 'readline'
require 'rl'

ns = RL::Eval::Namespace.new :user
ns.refers RL::Eval::Namespace[:rl]
context = RL::Eval::Context.new ns

while true
  input = Readline.readline("#{context.ns.name}=> ", true)
  if input.nil?
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
