# encoding: utf-8
require 'set'

module Rouge::Compiler
  class Resolved
    def initialize(inner)
      @inner = inner
    end

    attr_reader :inner
  end

  class Error < StandardError
    def initialize(inner)
      @inner = inner
    end

    def to_s
      "<#{self.class.name}: #{inner.inspect}>"
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
        head, *tail =
          Rouge::Builtins.send(
            "_compile_#{head.name}",
            ns, lexicals, *tail)
      else
        head = compile(ns, lexicals, head)
        if head.is_a?(Resolved) and
           head.inner.is_a?(Rouge::Var) and
           head.inner.deref.is_a?(Rouge::Macro) and
          # Also TODO: compiling function calls with blocks should put the
          # block args in scope. fun.
          # TODO: actually execute/expand the macro here!
          raise "MACRO"
        else
          tail = tail.map {|f| compile(ns, lexicals, f)}
        end
      end

      Rouge::Cons[head, *tail]
    else
      form
    end
  rescue => e
    if e.is_a?(Error)
      raise e
    else
      raise Error.new(e)
    end
  end
end

# vim: set sw=2 et cc=80:
