# encoding: utf-8

$: << "./lib"

require 'readline'
require 'piret'

ns = Piret::Eval::Namespace[:user]
ns.refers Piret::Eval::Namespace[:piret]
context = Piret::Eval::Context.new ns

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

# vim: set sw=2 et cc=80:
