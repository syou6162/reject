require 'pp'
class Fwrapper
  attr_accessor :function
  attr_accessor :childcount
  attr_accessor :name
  def initialize(function,childcount,name)
    @function = function
    @childcount = childcount
    @name = name
  end
  def deep_copy()
    return self.class.new(Proc.new{@function},
                          Marshal.load(Marshal.dump(@childcount)),
                          Marshal.load(Marshal.dump(@name)))
  end
end 

class AbstractNode
  #あったほうが安心した
  def evaluate()
  end
  def display()
  end
  def deep_copy()
  end
end

class Node < AbstractNode

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

  def display(indent=0)
    puts ' '*indent + @name
    @children.each{|c|
      c.display(indent+1)
    }
  end

  def deep_copy()
    #self.childrenにもFwrapperオブジェクトが入る場合があるので、再帰的にdeep copyをやっていく
    function = @function
    childcount =  Flist.map{|x|x.childcount if x.name == @name}.compact
    name = @name
    return self.class.new(Fwrapper.new(function,childcount,name).deep_copy,deep_copy_children)
  end

  def deep_copy_children()
    return @children.map{|c|
      if c.class == Node
        c.deep_copy
      else
        Marshal.load(Marshal.dump(c))
      end
    }
  end
end

class Paramnode < AbstractNode
  attr_accessor :idx
  def initialize(idx)
    @idx = idx
  end
  def evaluate(inp)
    return inp[@idx]
  end
  def display(indent=0)
    puts ' '*indent + @idx.to_s
  end
  def deep_copy()
    Marshal.load(Marshal.dump(self.class.new(@idx)))
  end
end

class Constnode < AbstractNode
  attr_accessor :v
  def initialize(v)
    @v = v
  end
  def evaluate(inp)
    return @v
  end
  def display(indent=0)
    puts ' '*indent + @v.to_s
  end
  def deep_copy()
    Marshal.load(Marshal.dump(self.class.new(@v)))
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

def makerandomtree(pc,maxdepth=4,fpr=0.5,ppr=0.6)
  include MyMethods
  if rand < fpr and maxdepth > 0
    f = Flist[rand(Flist.size)]
    children = (1..f.childcount).map{makerandomtree(pc,maxdepth-1,fpr,ppr)}
    return Node.new(f,children)
  elsif rand < ppr
    return Paramnode.new(rand(pc-1))
  else
    return Constnode.new(rand(10))
  end
end

def hiddenfunction(x,y)
  return x**2 + 2*y + 3*x +5
end

def buidhiddenset()
  rows = []
  (1..200).each{|i|
    x = rand(40)
    y = rand(40)
    rows.push([x,y,hiddenfunction(x,y)])
  }
  return rows
end

def scorefunction(tree,s)
  dif = 0
  s.each{|data|
    v = tree.evaluate([data[0],data[1]])
    dif += (v-data[2]).abs
  }
  return dif
end

def mutate(t,pc,probchange=0.1)
  if rand < probchange
    return makerandomtree(pc)
  else
    result = t.deep_copy
    if t.instance_variable_defined?("@children")
      result.children = t.children.each{|c|mutate(c,pc,probchange)}
    end
    return result
  end
end

def crossover(t1,t2,probswap=0.7,top=1)
  if rand < probswap and !top
    return t2.deep_copy
  else
    result = t1.deep_copy
    if t1.instance_variable_defined?("@children") && t2.instance_variable_defined?("@children")
      choice = t2.children[rand(t2.children.length)]
      result.children = t1.children.map{|c|crossover(c,choice,probswap,0)}
    end
  end
end

def selectindex()
  return Math::log(rand/log(pexp))
end

def evolve(pc,popsize,rankfunction,maxgen=500,mutationrate=0.1,breedingrate=0.4,pexp=0.7,pnew=0.05)
  population = (1..popsize.map{makerandomtree(pc)})
  (1..maxgen).each{|i|
    scores = rankfunction(population)
    puts scores[0][0]
    if scores[0][0] == 0
      breadk
    end
    newpop = [scores[0][1],scores[1][1]]
    while newpop.length < popsize
      if rand > pnew
        newpop.push mutate(crossover(scores[selectindex][1],
                                     scores[selectindex][1],
                                     probswap=breedingrate),
                                     pc,probchange=mutationratete)
      else
        newpop.push makerandomtree(pc)
      end
      population = newpop
    end
  }
  scores[0][1].display
  return scores[0][1]
end

