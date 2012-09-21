# encoding: utf-8
require 'rouge/wrappers'

class Rouge::Reader
  class UnexpectedCharacterError < StandardError; end
  class TrailingDataError < StandardError; end
  class EndOfDataError < StandardError; end

  def initialize(ns, input)
    @ns = ns
    @src = input
    @n = 0
  end

  def lex sub=false
    r =
      case peek
      when NUMBER
        number
      when /:/
        keyword
      when /"/
        string
      when /\(/
        Rouge::Cons[*list(')')].freeze
      when /\[/
        list ']'
      when /#/
        dispatch
      when SYMBOL
        # SYMBOL after \[ and #, because it includes both
        symbol
      when /{/
        map
      when /'/
        quotation
      when /`/
        backquotation
      when /~/
        dequotation
      when /\^/
        metadata
      when /@/
        deref
      when nil
        reader_raise EndOfDataError, "in #lex"
      else
        reader_raise UnexpectedCharacterError, "#{peek.inspect} in #lex"
      end

    if not sub
      while peek =~ /[\s,]/
        consume
      end
      if @n < @src.length
        reader_raise TrailingDataError, "remaining in #lex: #{@src[@n..-1]}"
      end
    end

    r
  end

  private

  def number
    slurp(NUMBER).gsub(/\D+/, '').to_i
  end

  def keyword
    begin
      slurp /:"/
      @n -= 1
      s = string
      s.intern
    rescue UnexpectedCharacterError
      slurp(/^:[a-zA-Z0-9\-_!\?\*\/]+/)[1..-1].intern
    end
  end

  def string
    s = ""
    t = consume
    while true
      c = @src[@n]

      if c.nil?
        reader_raise EndOfDataError, "in string, got: #{s}"
      end

      @n += 1

      if c == t
        break
      end

      if c == ?\\
        c = consume

        case c
        when nil
          reader_raise EndOfDataError, "in escaped string, got: #{s}"
        when /[abefnrstv]/
          c = {?a => ?\a,
               ?b => ?\b,
               ?e => ?\e,
               ?f => ?\f,
               ?n => ?\n,
               ?r => ?\r,
               ?s => ?\s,
               ?t => ?\t,
               ?v => ?\v}[c]
        else
          # Just leave it be.
        end
      end

      s += c
    end
    s.freeze
  end

  def list(ending)
    consume
    r = []

    while true
      if peek == ending
        break
      end
      r << lex(true)
    end

    consume
    r.freeze
  end

  def symbol
    Rouge::Symbol[slurp(SYMBOL).intern]
  end

  def map
    consume
    r = {}

    while true
      if peek == '}'
        break
      end
      k = lex(true)
      v = lex(true)
      r[k] = v
    end

    consume
    r.freeze
  end

  def quotation
    consume
    Rouge::Cons[Rouge::Symbol[:quote], lex(true)].freeze
  end

  def backquotation
    consume
    dequote lex(true)
  end

  def dequotation
    consume
    if peek == ?@
      consume
      Rouge::Splice[lex(true)]
    else
      Rouge::Dequote[lex(true)]
    end
  end

  def dequote form
    case form
    when Rouge::Cons, Array
      rest = []
      group = []
      form.each do |f|
        if f.is_a? Rouge::Splice
          if group.length > 0
            rest << Rouge::Cons[Rouge::Symbol[:list], *group].freeze
            group = []
          end
          rest << f.inner
        else
          group << dequote(f)
        end
      end

      if group.length > 0
        rest << Rouge::Cons[Rouge::Symbol[:list], *group].freeze
      end

      r =
        if rest.length == 1
          rest[0]
        else
          Rouge::Cons[Rouge::Symbol[:concat], *rest].freeze
        end

      if form.is_a?(Array)
        Rouge::Cons[Rouge::Symbol[:apply],
                    Rouge::Symbol[:vector],
                    r].freeze
      elsif rest.length > 1
        Rouge::Cons[Rouge::Symbol[:seq], r].freeze
      else
        r
      end
    when Hash
      Hash[*form.map {|k,v| [dequote(k), dequote(v)]}.flatten(1)]
    when Rouge::Dequote
      form.inner
    when Rouge::Symbol
      # qualify!
      if form.inner.to_s =~ /\//
        Rouge::Cons[Rouge::Symbol[:quote], form].freeze
      else
        begin
          var = @ns[form.inner]
          Rouge::Cons[Rouge::Symbol[:quote],
                      Rouge::Symbol[var.name]].freeze
        rescue Rouge::Namespace::VarNotFoundError
          Rouge::Cons[Rouge::Symbol[:quote],
                      Rouge::Symbol[:"#{@ns.name}/#{form.inner}"]].freeze
        end
      end
    else
      Rouge::Cons[Rouge::Symbol[:quote], form].freeze
    end
  end

  def dispatch
    consume
    case peek
    when '('
      body, count = dispatch_rewrite_fn(lex(true), 0)
      Rouge::Cons[
          Rouge::Symbol[:fn],
          (1..count).map {|n| Rouge::Symbol[:"%#{n}"]}.freeze,
          body].freeze
    when "'"
      consume
      Rouge::Cons[Rouge::Symbol[:var], lex(true)].freeze
    else
      reader_raise UnexpectedCharacterError, "#{peek.inspect} in #dispatch"
    end
  end

  def dispatch_rewrite_fn form, count
    case form
    when Rouge::Cons, Array
      mapped = form.map do |e|
        e, count = dispatch_rewrite_fn(e, count)
        e
      end

      if form.is_a?(Rouge::Cons)
        [Rouge::Cons[*mapped].freeze, count]
      else
        [mapped, count]
      end
    when Rouge::Symbol
      if form.inner == :"%"
        [Rouge::Symbol[:"%1"], [1, count].max]
      elsif form.inner.to_s =~ /^%(\d+)$/
        [form, [$1.to_i, count].max]
      else
        [form, count]
      end
    else
      [form, count]
    end
  end

  def metadata
    consume
    meta = lex(true)
    attach = lex(true)

    if not attach.class < Rouge::Metadata
      reader_raise ArgumentError,
          "metadata can only be applied to classes mixing in Rouge::Metadata"
    end

    meta =
      case meta
      when Symbol
        {meta => true}
      when String
        {:tag => meta}
      else
        meta
      end

    extant = attach.meta
    if extant.nil?
      attach.meta = meta
    else
      attach.meta = extant.merge(meta)
    end

    attach
  end

  def deref
    consume
    Rouge::Cons[Rouge::Symbol[:"rouge.core/deref"], lex(true)].freeze
  end

  def slurp re
    @src[@n..-1] =~ re
    reader_raise UnexpectedCharacterError, "#{@src[@n]} in #slurp #{re}" if !$&
    @n += $&.length
    $&
  end

  def peek
    while @src[@n] =~ /[\s,;]/
      if $& == ";"
        while @src[@n] =~ /[^\n]/
          @n += 1
        end
      else
        @n += 1
      end
    end

    @src[@n]
  end

  def consume
    c = peek
    @n += 1
    c
  end

  def reader_raise ex, m
    around = 
        "#{@src[[@n - 3, 0].max...[@n, 0].max]}" +
        "#{@src[@n]}" +
        "#{(@src[@n + 1..@n + 3] || "").gsub(/\n.*$/, '')}"

    line = @src[0...@n].count("\n") + 1
    char = @src[0...@n].reverse.index("\n") || 0 + 1

    raise ex, 
        "around: #{around}\n" +
        "           ^\n" +
        "line #{line} char #{char}: #{m}"
  end

  NUMBER = /^[0-9][0-9_]*/
  SYMBOL = /^(\.\[\])|([a-zA-Z0-9\-_!&\?\*\/\.\+\|=%$<>#]+)/
end

# vim: set sw=2 et cc=80:
