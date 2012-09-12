# encoding: utf-8
require 'rouge/context'
require 'rouge/builtins'

class Rouge::Namespace
  @namespaces = {}

  class RecursiveNamespaceError < StandardError; end

  def initialize(name)
    @name = name
    @table = {}
    @refers = []
  end

  def refer(ns)
    if ns.name == @name
      raise RecursiveNamespaceError, "#@name will not refer #{ns.name}"
    end

    @refers << ns if not @refers.include? ns
  end

  def [](key)
    if @table.include? key
      return @table[key]
    end

    @refers.each do |ns|
      begin
        return ns[key]
      rescue Rouge::Eval::BindingNotFoundError
        # no-op
      end
    end

    raise Rouge::Eval::BindingNotFoundError, key
  end

  def set_here(key, value)
    @table[key] = value
  end

  attr_reader :name, :refers
end

class << Rouge::Namespace
  def exists?(ns)
    @namespaces.include? ns
  end

  def [](ns)
    r = @namespaces[ns]
    return r if r

    self[ns] = new(ns)
    @namespaces[ns] = new(ns)
  end

  def []=(ns, value)
    @namespaces[ns] = value
  end

  def destroy(ns)
    @namespaces.delete ns
  end
end

class Rouge::Namespace::Ruby
  def [](name)
    Kernel.const_get name
  rescue NameError
    raise Rouge::Eval::BindingNotFoundError
  end

  def set_here(name, value)
    Kernel.const_set name, value
  end

  def name
    :ruby
  end
end

ns = Rouge::Namespace[:"rouge.builtin"]
Rouge::Builtins.methods(false).each do |m|
  ns.set_here m, Rouge::Builtin[Rouge::Builtins.method(m)]
end
Rouge::Builtins::SYMBOLS.each do |name, val|
  ns.set_here name, val
end

Rouge::Namespace[:ruby] = Rouge::Namespace::Ruby.new

# vim: set sw=2 et cc=80:
