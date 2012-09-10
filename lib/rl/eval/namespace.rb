# encoding: utf-8
require 'rl/eval/context'
require 'rl/eval/builtins'

class RL::Eval::Namespace
  @@namespaces = {}

  def initialize(name)
    @name = name
    @table = {}
    @refers = []
  end

  def refers(ns)
    @refers << ns if not @refers.include? ns
  end

  def [](key)
    if @table.include? key
      return @table[key]
    end

    @refers.each do |ns|
      begin
        return ns[key]
      rescue RL::Eval::BindingNotFoundError
        # no-op
      end
    end

    raise RL::Eval::BindingNotFoundError, key
  end

  def set_here(key, value)
    @table[key] = value
  end

  attr_reader :name
end

class << RL::Eval::Namespace
  def [](ns)
    r = RL::Eval::Namespace.class_variable_get('@@namespaces')[ns]
    return r if r

    if not self.respond_to?(:"vivify_#{ns}", true)
      return nil
    end

    self[ns] = send(:"vivify_#{ns}")
  end

  def []=(ns, value)
    RL::Eval::Namespace.class_variable_get('@@namespaces')[ns] = value
  end

  private

  def vivify_rl
    ns = new :rl
    RL::Eval::Builtins.methods(false).each do |m|
      ns.set_here m, RL::Builtin[RL::Eval::Builtins.method(m)]
    end
    RL::Eval::Builtins::SYMBOLS.each do |name, val|
      ns.set_here name, val
    end
    ns.refers self[:r]
    ns
  end

  def vivify_r
    RL::Eval::Namespace::R.new
  end
end

class RL::Eval::Namespace::R
  def [](name)
    Kernel.const_get name
  rescue NameError
    raise RL::Eval::BindingNotFoundError
  end

  def set_here(name, value)
    Kernel.const_set name, value
  end

  def name
    :r
  end
end

# vim: set sw=2 et cc=80:
