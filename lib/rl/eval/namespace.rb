# encoding: utf-8
require 'rl/eval/context'
require 'rl/eval/builtins'

class RL::Eval::Namespace < RL::Eval::Context
  @@namespaces = {}

  def initialize(name)
    @name = name
    super nil
  end

  undef set_lexical
  undef ns

  attr_reader :name
end

class RL::Eval::Namespace::R < RL::Eval::Namespace
  def initialize
    super :r
  end

  def [](name)
    Kernel.const_get name
  end

  def set_here(name, value)
    Kernel.const_set name, value
  end
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
    ns
  end

  def vivify_r
    RL::Eval::Namespace::R.new
  end
end

# vim: set sw=2 et cc=80:
