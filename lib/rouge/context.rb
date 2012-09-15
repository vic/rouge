# encoding: utf-8

class Rouge::Context
  def initialize(parent_or_ns)
    case parent_or_ns
    when Rouge::Namespace
      @ns = parent_or_ns
    when Rouge::Context
      @parent = parent_or_ns
      @ns = @parent.ns
    end
    @table = {}
  end

  def [](key)
    if @table.include? key
      @table[key]
    elsif @parent
      @parent[key]
    elsif @ns
      @ns[key]
    else
      raise Rouge::Eval::BindingNotFoundError, key
    end
  end

  def set_here(key, value)
    @table[key] = value
  end

  def set_lexical(key, value)
    if @table.include? key
      @table[key] = value
    elsif @parent
      @parent.set_lexical key, value
    else
      raise Rouge::Eval::BindingNotFoundError,
          "setting #{key} to #{value.inspect}"
    end
  end

  def readeval(input)
    Rouge.eval(self, Rouge.read(input))
  end

  # +symbol+ should be a Ruby Symbol or String, not a Rouge::Symbol.
  def locate(symbol)
    symbol = symbol.to_s

    will_new =
      if symbol[-1] == ?.
        symbol = symbol[0..-2]
        true
      end

    ns, name =
      symbol == "/" ? [nil, "/"] : symbol.match(/^(?:(.*)\/)?(.*)$/).captures

    if ns.nil?
      sub = self
    else
      sub = Rouge::Namespace[ns.intern]
    end

    lookups = name.split(/(?<=.)\.(?=.)/)
    sub = sub[lookups.shift.intern]

    while lookups.length > 0
      sub = sub.deref if sub.is_a?(Rouge::Var)
      sub = sub.const_get(lookups.shift.intern)
    end

    if will_new
      sub = sub.deref if sub.is_a?(Rouge::Var)
      sub.method(:new)
    else
      sub
    end
  end

  attr_reader :ns
end

# vim: set sw=2 et cc=80:
