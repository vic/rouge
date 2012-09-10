# encoding: utf-8
require 'piret/core'

module Piret::Eval
  require 'piret/eval/context'
  require 'piret/eval/namespace'

  class BindingNotFoundError < StandardError; end
end

class << Piret::Eval
  def eval(context, *forms)
    return nil if forms.length.zero?

    while true
      form = forms.shift
      r =
        case form
        when Symbol
          form = form.to_s
          if form[0] == ?.
            form = form[1..-1]
            lambda {|receiver, *args|
              receiver.send(form, *args)
            }
          else
            will_new =
              if form[-1] == ?.
                form = form[0..-2]
                true
              end

            parts = form.split("/")

            if parts.length == 1
              sub = context
            elsif parts.length == 2
              sub = Piret::Eval::Namespace[parts.shift.intern]
            else
              raise "parts.length not in 1, 2" # TODO
            end

            lookups = parts[0].split(/(?<=.)\.(?=.)/)
            sub = sub[lookups.shift.intern]

            while lookups.length > 0
              sub = sub.const_get(lookups.shift.intern)
            end

            if will_new
              sub.method(:new)
            else
              sub
            end
          end
        when Piret::Cons
          fun = eval context, form[0]
          remainder = form[1..-1]
          case fun
          when Piret::Builtin
            fun.inner.call context, *form.to_a[1..-1]
          when Piret::Macro
            eval context, fun.inner.call(*form.to_a[1..-1])
          else
            fun.call *form.to_a[1..-1].map {|f| eval context, f}
          end
        when Hash
          Hash[*
              form.map {|k,v| [eval(context, k), eval(context, v)]}.flatten(1)]
        when Array
          form.map {|f| eval context, f}
        else
          form
        end

      return r if forms.length.zero?
    end
  end
end

# vim: set sw=2 et cc=80:
