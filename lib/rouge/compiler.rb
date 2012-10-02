# encoding: utf-8
require 'set'

module Rouge::Compiler; end

class << Rouge::Compiler
  def compile(ns, lexicals, form)
    case form
    when Rouge::Symbol
      if form.ns or lexicals.include?(form.name) or form.name[0] == ?.
        # TODO: cache found ns/var/context or no. of context parents.
        form
      else
        ns[form.name] # TODO: cache result
        form
      end
    when Rouge::Cons
      head, *tail = form.to_a

      if head.is_a?(Rouge::Symbol) and
         head.ns.nil? and
         Rouge::Builtins.respond_to?("_compile_#{head.name}")
        head, *tail =
          Rouge::Builtins.send(
            "_compile_#{head.name}",
            ns, lexicals, *tail)
      else
        head = compile(ns, lexicals, head)
        tail = tail.map {|f| compile(ns, lexicals, f)}
      end

      Rouge::Cons[head, *tail]
    else
      form
    end
  end
end

# vim: set sw=2 et cc=80:
