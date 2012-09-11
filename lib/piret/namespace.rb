# encoding: utf-8
require 'piret/context'
require 'piret/builtins'

class Piret::Namespace
  @@namespaces = {}

  def initialize(name)
    @name = name
    @table = {}
    @refers = []
  end

  def refer(ns)
    @refers << ns if not @refers.include? ns
  end

  def [](key)
    if @table.include? key
      return @table[key]
    end

    @refers.each do |ns|
      begin
        return ns[key]
      rescue Piret::Eval::BindingNotFoundError
        # no-op
      end
    end

    raise Piret::Eval::BindingNotFoundError, key
  end

  def set_here(key, value)
    @table[key] = value
  end

  attr_reader :name, :refers
end

class << Piret::Namespace
  def exists?(ns)
    Piret::Namespace.class_variable_get('@@namespaces').include? ns
  end

  def [](ns)
    r = Piret::Namespace.class_variable_get('@@namespaces')[ns]
    return r if r

    Piret::Namespace.class_variable_get('@@namespaces')[ns] = new(ns)
  end
end

class Piret::Namespace::Ruby
  def [](name)
    Kernel.const_get name
  rescue NameError
    raise Piret::Eval::BindingNotFoundError
  end

  def set_here(name, value)
    Kernel.const_set name, value
  end

  def name
    :ruby
  end
end

class Piret::Namespace
  ns = @@namespaces[:"piret.builtin"] = Piret::Namespace.new :"piret.builtin"
  Piret::Builtins.methods(false).each do |m|
    ns.set_here m, Piret::Builtin[Piret::Builtins.method(m)]
  end
  Piret::Builtins::SYMBOLS.each do |name, val|
    ns.set_here name, val
  end

  @@namespaces[:ruby] = Piret::Namespace::Ruby.new
end

# vim: set sw=2 et cc=80:
