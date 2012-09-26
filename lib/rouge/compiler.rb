# encoding: utf-8

module Rouge::Compiler; end

class << Rouge::Compiler
  def compile(form, out)
    case form
    when Fixnum
      out << form.inspect
    when String
      out << form.inspect
    when Rouge::Symbol
      if form.ns.nil?
        out << ruby_label(form.name)
      else
        raise NotImplementedError, "R::Symbol, ns ≠ nil"
      end
    when Rouge::Cons
      compile(form[0], out)
      out << ".call("
      form[1..-1].each.with_index do |arg, i|
        out << ", " unless i.zero?
        compile(arg, out)
      end
      out << ")"
    else
      raise ArgumentError, "cannot compile: #{form.inspect}"
    end
  end

  private

  def ruby_label(sym)
    sym.to_s.gsub(/-/, '_')
  end
end

# vim: set sw=2 et cc=80:
