# encoding: utf-8

class RL::Eval::Context
  def initialize(parent_or_ns)
    case parent_or_ns
    when RL::Eval::Namespace
      @ns = parent_or_ns
    when RL::Eval::Context
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
      raise RL::Eval::BindingNotFoundError, key
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
      raise RL::Eval::BindingNotFoundError,
          "setting #{key} to #{value.inspect}"
    end
  end

  attr_reader :ns
end

# vim: set sw=2 et cc=80:
