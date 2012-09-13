# encoding: utf-8
require 'rouge/wrappers'

module Rouge::Printer
  class UnknownFormError < StandardError; end

  def self.print(form)
    case form
    when Integer
      form.to_s
    when Rouge::Symbol
      form.inner.to_s
    when Symbol
      form.inspect
    when String
      form.inspect
    when Array
      "[#{form.map {|e| print e}.join " "}]"
    when Rouge::Cons::Empty
      "()"
    when Rouge::Cons
      if form.length == 2 and form[0] == Rouge::Symbol[:quote]
        "'#{print form[1]}"
      elsif form.length == 2 and form[0] == Rouge::Symbol[:var]
        "#'#{print form[1]}"
      else
        "(#{form.map {|e| print e}.join " "})"
      end
    when Rouge::Var
      "#'#{form.name}"
    when Hash
      "{#{form.map {|k,v| print(k) + " " + print(v)}.join ", "}}"
    when NilClass
      "nil"
    when TrueClass
      "true"
    when FalseClass
      "false"
    when Class, Module
      if form.name
        "ruby/#{form.name.split('::').join('.')}"
      else
        form.inspect
      end
    when Rouge::Builtin
      "rouge.builtin/#{form.inner.name}"
    else
      form.inspect
    end
  end
end

# vim: set sw=2 et cc=80:
