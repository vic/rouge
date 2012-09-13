# encoding: utf-8

class Rouge::Var
  @@stack = []

  def initialize(name, root=Rouge::Var::Unbound)
    @name = name
    @root = root
  end

  def ==(var)
    var.is_a?(Rouge::Var) and @name == var.name and @root == var.root
  end

  attr_reader :name
  
  def root
    @@stack.reverse_each do |map|
      if map.include? @name
        return map[@name]
      end
    end
    @root
  end

  def self.push(map)
    @@stack << map
  end

  def self.pop
    @@stack.pop
  end
end

Rouge::Var::Unbound = Object.new

# vim: set sw=2 et cc=80:
