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
  def initialize(getfeatures)
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
  def categories()
    return @cc.keys
  end
  def train(item,cat)
    @getfeatures.call(item).each{|f|
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
    basicprob = prf.call(f,cat)
    totals = 0.0
    categories.each{|c|
      totals = fcount(f,c)
    }
    bp = ((weight * ap) + (totals * basicprob)) / (weight + totals)
    return bp
  end
end

class NaiveBayes < Classifier
  attr_accessor = :thresholds 
  def initialize(getfeatures)
    super(getfeatures)
    @thresholds = {} 
  end
  def docprob(item,cat)
    features = @getfeatures.call(item)
    p = 1.0
    features.each{|f|
      p *= weightdprob(f,cat,self.method(:fprob))
    }
    return p
  end
  def prob(item,cat)
    catprob = catcount(cat) / totalcount()
    docprob = docprob(item,cat)
    return docprob * catprob
  end
  def setthresholds(cat,t)
    @thresholds[cat] = t
  end
  def getthresholds(cat)
    if !@thresholds.include?(cat)
      return 1.0
    else
      return @thresholds[cat]
    end
  end
  def classify(item,default=nil)
    probs = {}
    max = 0.0
    best = nil
    categories.each{|cat|
      probs[cat] = prob(item,cat)
      if probs[cat] > max
        max = probs[cat]
        best = cat
      end
    }
    probs.keys.each{|cat|
      next if cat == best
      if probs[cat] * getthresholds(best) > probs[best]
        return default
      end
    }
    return best
  end
end
