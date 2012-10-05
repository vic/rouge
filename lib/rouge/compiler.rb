# encoding: utf-8
require 'set'

module Rouge::Compiler
  class Resolved
    def initialize(inner)
      @inner = inner
    end

    attr_reader :inner
  end

  def self.compile(ns, lexicals, form)
    case form
    when Rouge::Symbol
      if form.ns or
         lexicals.include?(form.name) or
         form.name[0] == ?. or 
         (form.name[-1] == ?. and
            lexicals.include?(form.name[0..-2].to_sym)) or
         [:|, :&].include?(form.name)
        # TODO: cache found ns/var/context or no. of context parents.
        form
      else
        Resolved.new ns[form.name]
      end
    when Rouge::Cons
      head, *tail = form.to_a

      if head.is_a?(Rouge::Symbol) and
         head.ns.nil? and
         Rouge::Builtins.respond_to?("_compile_#{head.name}")
        Rouge::Cons[*
          Rouge::Builtins.send(
            "_compile_#{head.name}",
            ns, lexicals, *tail)]
      else
        head = compile(ns, lexicals, head)

        # XXX ↓↓↓ This is insane ↓↓↓
        if head.is_a?(Resolved) and
           head.inner.is_a?(Rouge::Var) and
           head.inner.deref.is_a?(Rouge::Macro)
          # Also TODO: compiling function calls with blocks should put the
          # block args in scope. fun.
          # TODO: backtrace_fix
          compile(ns, lexicals, head.inner.deref.inner.call(*tail))
        else
          Rouge::Cons[head, *tail.map {|f| compile(ns, lexicals, f)}]
        end
      end
    else
      form
    end
  end
end

# vim: set sw=2 et cc=80:
