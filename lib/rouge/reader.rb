# encoding: utf-8
require 'rouge/wrappers'

class Rouge::Reader
  class UnexpectedCharacterError < StandardError; end
  class TrailingDataError < StandardError; end
  class EndOfDataError < StandardError; end

  def self.read(input)
    new(input).lex
  end

  def initialize(input)
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
        Rouge::Cons[*list(')')]
      when /\[/
        list ']'
      when SYMBOL
        # SYMBOL after \[, because it includes \[
        symbol
      when /{/
        map
      when /'/
        quotation
      when /`/
        backquotation
      when /~/
        dequotation
      when /#/
        dispatch
      when nil
        raise EndOfDataError, "in #lex"
      else
        raise UnexpectedCharacterError, "#{peek.inspect} in #lex"
      end

    if not sub
      while peek =~ /[\s,]/
        consume
      end
      if @n < @src.length
        raise TrailingDataError, "remaining in #lex: #{@src[@n..-1]}"
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
        raise EndOfDataError, "in string, got: #{s}"
      end

      @n += 1

      if c == t
        break
      end

      if c == ?\\
        c = consume

        case c
        when nil
          raise EndOfDataError, "in escaped string, got: #{s}"
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
    s
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
    r
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
    r
  end

  def quotation
    consume
    Rouge::Cons[Rouge::Symbol[:quote], lex(true)]
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
    when Rouge::Cons
      rest = []
      group = []
      form.each do |f|
        if f.is_a? Rouge::Splice
          if group.length > 0
            rest << Rouge::Cons[Rouge::Symbol[:list], *group]
            group = []
          end
          rest << f.inner
        else
          group << dequote(f)
        end
      end

      if group.length > 0
        rest << Rouge::Cons[Rouge::Symbol[:list], *group]
      end

      if rest.length == 1
        rest[0]
      else
        Rouge::Cons[Rouge::Symbol[:concat], *rest]
      end
    when Rouge::Dequote
      form.inner
    else
      Rouge::Cons[Rouge::Symbol[:quote], form]
    end
  end

  def dispatch
    consume
    if peek == '('
      body, count = dispatch_rewrite(lex(true), 0)
      Rouge::Cons[
          Rouge::Symbol[:fn],
          (1..count).map {|n| Rouge::Symbol[:"%#{n}"]},
          body]
    else
      raise UnexpectedCharacterError, "#{peek}.inspect in #dispatch"
    end
  end

  def dispatch_rewrite form, count
    [form, count]
  end

  def slurp re
    @src[@n..-1] =~ re
    raise UnexpectedCharacterError, "#{@src[@n]} in #slurp #{re}" if !$&
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

  NUMBER = /^[0-9][0-9_]*/
  SYMBOL = /^(\.\[\])|([a-zA-Z0-9\-_!&\?\*\/\.\+\|=%]+)/
end

# vim: set sw=2 et cc=80:
