
class Fwrapper
  attr_accessor :function
  attr_accessor :childcount
  attr_accessor :name
  def initialize(function,childcount,name)
    @function = function
    @childcount = childcount
    @name = name
  end
end

class Node
  attr_accessor :function
  attr_accessor :name
  attr_accessor :children
  def initialize(fw,children)
    @function = fw.function
    @name = fw.name
    @children = children
  end
  def evaluate(inp)
    results = @children.map{|n| n.evaluate(inp)}
    return @function.call(results)
  end
end

class Paramnode
  attr_accessor :idx
  def initialize(idx)
    @idx = idx
  end
  def evaluate(inp)
    return inp[@idx]
  end
end

class Constnode
  attr_accessor :v
  def initialize(v)
    @v = v
  end
  def evaluate(inp)
    return @v
  end
end

module MyMethods
  Addw = Fwrapper.new(lambda{|l|l[0]+l[1]},2,'add')
  Subw = Fwrapper.new(lambda{|l|l[0]-l[1]},2,'subtract')
  Mulw = Fwrapper.new(lambda{|l|l[0]*l[1]},2,'multiply')

  def iffunc(l)
    if l[0] > 0
      return l[1]
    else
      return l[2]
    end
  end
  module_function :iffunc

  Ifw = Fwrapper.new(self.method(:iffunc),3,'if')

  def isgreater(l)
    if l[0] > l[1]
      return 1
    else
      return 0
    end
  end
  module_function :isgreater

  Gtw = Fwrapper.new(self.method(:isgreater),2,'isgreater')

  Flist = [Addw,Mulw,Ifw,Gtw,Subw]
end

def exampletree()
  include MyMethods
  return Node.new(Ifw,[
                  Node.new(Gtw,[Paramnode.new(0),Constnode.new(3)]),
                  Node.new(Addw,[Paramnode.new(1),Constnode.new(5)]),
                  Node.new(Subw,[Paramnode.new(1),Constnode.new(2)]),
  ])
end

