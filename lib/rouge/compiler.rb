# encoding: utf-8
require 'set'

module Rouge::Compiler; end

class << Rouge::Compiler
  def compile(ns, lexicals, form)
    case form
    when Rouge::Symbol
      will_new = form.name_s[-1] == ?.

      if form.ns.nil?
        sub = self
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

      if will_new
        sub = sub.deref if sub.is_a?(Rouge::Var)
        sub.method(:new)
      else
        sub
      end
    when Rouge::Cons
      cons = form.to_a
      if cons[0].is_a? Rouge::Symbol
        if lexicals.include? cons[0]
          Rouge::Cons[cons[0], *cons[1..-1].map {|f| compile(ns, lexicals, f)}]
        else
          #TODO...
        end
      else
        raise ArgumentError, "wah"
      end
    else
      form
    end
  end
end

# vim: set sw=2 et cc=80:
