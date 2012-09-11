# encoding: utf-8
require 'piret/core'

module Piret::Printer
  class UnknownFormError < StandardError; end

  def self.print(form)
    case form
    when Integer
      form.to_s
    when Piret::Symbol
      form.inner.to_s
    when Symbol
      form.inspect
    when String
      form.inspect
    when Array
      "[#{form.map {|e| print e}.join " "}]"
    when Piret::Cons::Empty
      "()"
    when Piret::Cons
      if form.length == 2 and form[0] == Piret::Symbol[:quote]
        "'#{print form[1]}"
      else
        "(#{form.map {|e| print e}.join " "})"
      end
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
    when Piret::Builtin
      "piret/#{form.inner.name}"
    else
      form.inspect
    end
  end
end

# vim: set sw=2 et cc=80:
