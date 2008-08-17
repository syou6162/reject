require 'rubygems'
require 'MeCab'
require 'pp'

def getwords(doc)
  doc.split(" ").uniq
end
def sampletrain(cl)
  cl.train('Nobody owns the water.','good')
  cl.train('the quick rabbit jumps fences','good')
  cl.train('buy pharmaceutical now','bad')
  cl.train('make quick money at the online casino','bad')
  cl.train('the quick brown fox jumps','good')
end

class Classifier
  attr_accessor :fc
  attr_accessor :cc
  attr_accessor :getfeatures
  def initialize(getfeatures,filename=nil)
    @fc = Hash.new({})
    @cc = Hash.new(0.0) 
    @getfeatures = getfeatures
  end
  def incf(f,cat)
    if !@fc.has_key?(f)
      @fc[f] = Hash.new(0.0)
    end
    @fc[f][cat] += 1.0
  end
  def incc(cat)
    @cc[cat] += 1.0
  end
  def fcount(f,cat)
    if @fc.has_key?(f) && @cc.has_key?(cat)
      return @fc[f][cat]
    else
      return 0.0
    end
  end
  def catcount(cat)
    if @cc.has_key?(cat)
      return @cc[cat]
    else
      return 0.0
    end
  end
  def totalcount()
    sum = 0.0
    @cc.values.each{|v|
      sum += v
    }
    return sum
  end
  def train(item,cat)
    features = Object.new.method(@getfeatures)
    features.call(item).each{|f|
      incf(f,cat)
    }
    incc(cat)
  end
  def fprob(f,cat)
    if catcount(cat) == 0.0
      return 0.0
    else
      fcount(f,cat) / catcount(cat)
    end
  end
  def weightdprob(f,cat,prf,weight=1.0,ap=0.5)
    basicprob = prf(f,cat)
    #ここから
    #
  end
end
