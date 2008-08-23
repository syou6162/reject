#関数のラッパークラス
setClass("fwrapper", representation(f="function", childcount="numeric",name="character"))

#何かよく分からないけど、必要っぽい
#ToDo:後で調べる
setGeneric("evaluate", function(this,inp) standardGeneric("evaluate"))
setGeneric("display", function(this,indent=0) standardGeneric("display"))

#nodeクラスの定義
setClass("node", representation(fw="fwrapper", children = "list"))

setGeneric("evaluate.node", function(this,inp) standardGeneric("evaluate.node"))
setMethod("evaluate","node",function(this,inp){
  result <- unlist(Map(function(x){evaluate(x,inp)},this@children),recursive=FALSE)
  return(this@fw@f(result))
})

setGeneric("display.node", function(this,indent) standardGeneric("display.node"))
setMethod("display","node",function(this,indent){
  cat(paste(Reduce(function(init,x){paste(init,x,sep="")},rep(" ",indent),""),this@fw@name,sep=""),fill=TRUE)
  for(c in this@children){
    display(c,indent+1)
  }
})

#paramnodeクラスの定義
setClass("paramnode", representation(idx = "numeric"))
setGeneric("evaluate.paramnode",function(this,inp){
  standardGeneric("evaluate.paramnode")
})
setMethod("evaluate","paramnode",function(this,inp){
  #PythonとRのoriginの違いを吸収するために1を足す
  return(inp[this@idx +1])
})

setGeneric("display.paramnode",function(this,indent){
  standardGeneric("display.paramnode")
})
setMethod("display","paramnode",function(this,indent){
  cat(sprintf("%sp%d",
            Reduce(function(init,x){paste(init,x,sep="")},rep(" ",indent),""),
            this@idx)
      ,fill=TRUE)
})

#constnodeクラスの定義
setClass("constnode", representation(v = "numeric"))
setGeneric("evaluate.constnode",function(this,inp){
  standardGeneric("evaluate.constnode")
})
setMethod("evaluate",signature(this="constnode"),function(this,inp){
  return(this@v)
})
setGeneric("display.constnode",function(this,indent){
  standardGeneric("display.constnode")
})
sprintf("%d%s",0,"hoge")

setMethod("display","constnode",function(this,indent){
  cat(sprintf("%s%d",
              Reduce(function(init,x){paste(init,x,sep="")},rep(" ",indent),""),
              this@v),
      fill=TRUE)
})

#関数のラッパークラスのインスタンス群
addw <- new("fwrapper",f=function(x){return(x[1]+x[2])},childcount=2,name="add")
subw <- new("fwrapper",f=function(x){return(x[1]-x[2])},childcount=2,name="subtract")
mulw <- new("fwrapper",f=function(x){return(x[1]*x[2])},childcount=2,name="multiply")

ifw <- new("fwrapper",f=function(x){
  return(ifelse(x[1] > 0,x[2],x[3]))
},childcount=3,name="if")

gtw <- new("fwrapper",f=function(x){
  return(ifelse(x[1] > x[2],1,0))
},childcount=2,name="isgreater")

flist <- c(addw,mulw,subw,ifw,gtw)

exampletree <- function(){
  return(new("node",fw=ifw,
             children=c(
               new("node",fw=gtw,children=c(
                                   new("paramnode",idx=0),new("constnode",v=3)
                                   )),
               new("node",fw=addw,children=c(
                                    new("paramnode",idx=1),new("constnode",v=5)
                                    )),
               new("node",fw=subw,children=c(
                                    new("paramnode",idx=1),new("constnode",v=2)
                                    ))
               )
             ))
}


flist[[3]]@childcount


seq(length(flist))

mapply(function(x){flist[[x]]@childcount},seq(length(flist)))


unlist(sample(flist,1))
is.numeric(sample(0:3,1))

makerandomtree <- function(pc,maxdepth=4,fpr=0.5,ppr=0.6){
  if((runif(1) < fpr) && (maxdepth > 0)){
    f <- sample(flist,1)[[1]]
    children <- Map(function(x){makerandomtree(pc,maxdepth-1,fpr,ppr)},seq(f@childcount))
    return(new("node",fw=f,children=children))
  }else if(runif(1) < ppr){
    return(new("paramnode",idx=sample(0:(pc-1),1)))
  }else{
    return(new("constnode",v=sample(0:10,1)))
  }
}

hiddenfunction <- function(x,y){
  return(x^2 + 2*y + 3*x +5)
}

buidhiddenset <- function(){
  rows <- matrix(0,200,3,byrow = TRUE)
  for(i in seq(200)){
    x <- sample(0:40,1)
    y <- sample(0:40,1)
    rows[i,] <- c(x,y,hiddenfunction(x,y))
  }
  return(rows)
}


nrow(buidhiddenset())

scorefunction <- function(tree,s){
  dif <- 0
  for(i in seq(nrow(s))){
    v <- evaluate(tree,c(s[i,1],s[i,2]))
    dif = dif + abs(v-s[i,3])
  }
  return(dif)
}

scorefunction(makerandomtree(2),buidhiddenset())


mutate <- function(t,pc,probchange=0.1){
  if(runif(1) < probchange){
    return(makerandomtree(2))
  }else{
    result <- t
    if(class(t)=="node"){
      result@children <- Map(function(c){mutate(c,pc,probchange)},t@children)
    }
    return(result)
  }
}
m




list

buidhiddenset()

m <- makerandomtree(2)
display(m)
display(mutate(m,2))


evaluate(m,c(1,4))



display(exampletree())

evaluate(exampletree(),c(5,3))
