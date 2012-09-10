# encoding: utf-8
require 'rl/eval/context'
require 'rl/eval/builtins'

class RL::Eval::Namespace < RL::Eval::Context
  @@namespaces = {}

  undef set_lexical
  undef ns
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
    ns = new nil
    RL::Eval::Builtins.methods(false).each do |m|
      ns.set_here m, RL::Builtin[RL::Eval::Builtins.method(m)]
    end
    RL::Eval::Builtins::SYMBOLS.each do |name, val|
      ns.set_here name, val
    end
    ns
  end

  def vivify_r
    Kernel
  end
end

# vim: set sw=2 et cc=80:
