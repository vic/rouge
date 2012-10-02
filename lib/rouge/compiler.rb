# encoding: utf-8
require 'set'

module Rouge::Compiler; end

class << Rouge::Compiler
  def compile(ns, lexicals, form)
    case form
    when Rouge::Symbol
      if form.ns.nil? and lexicals.include?(form.name)
        return form
      end

      will_new = form.name_s[-1] == ?.

      if form.ns.nil?
        sub = ns
      else
        sub = Rouge::Namespace[form.ns]
      end

      lookups = form.name_parts
      sub = sub[lookups[0]]
      i, count = 1, lookups.length

      while i < count
        sub = sub.deref if sub.is_a?(Rouge::Var)
        sub = sub.const_get(lookups[i])
        i += 1
      end

      # HACK(arlen): this should likely return something compiler-specific,
      # not just a quote.
      if will_new
        sub = sub.deref if sub.is_a?(Rouge::Var)
        Rouge::Cons[Rouge::Symbol[:quote],
                    sub.method(:new)]
      else
        Rouge::Cons[Rouge::Symbol[:quote],
                    sub]
      end
    when Rouge::Cons
      head, *tail = form.to_a

      head = compile(ns, lexicals, head)
      if head.is_a?(Rouge::Cons) and head.length == 2 and
         head[0] == Rouge::Symbol[:quote] and
         head[1].is_a?(Rouge::Var) and
         head[1].deref.is_a?(Rouge::Builtin)
        head, *tail = Rouge::Builtins.send "_compile_#{head[1].deref.inner.name}", ns, lexicals, *tail
      else
        STDERR.puts "head: #{head.inspect}"
        tail = tail.map {|f| compile(ns, lexicals, f)}
      end

      Rouge::Cons[head, *tail]
    else
      form
    end
  end
end

# vim: set sw=2 et cc=80:
