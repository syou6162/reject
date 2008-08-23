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

scorefunction <- function(tree,s){
  dif <- 0
  for(i in seq(nrow(s))){
    v <- evaluate(tree,c(s[i,1],s[i,2]))
    dif = dif + abs(v-s[i,3])
  }
  return(dif)
}

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

crossover <- function(t1,t2,probswap=0.7,top=1){
  if((runif(1) < probswap) && (top != 0)){
    return(t2)
  }else{
    result <- t1
    if((class(t1)=="node") && (class(t2)=="node")){
      result@children <- unlist(Map(function(c){crossover(c,sample(t2@children,1))},t1@children),recursive=FALSE)
    }
    return(result)
  }
}

evolve <- function(pc,popsize,rankfunction,maxgen=50,mutationrate=0.1,breedingrate=0.4,pexp=0.7,pnew=0.05){
  selectindex <- function(){
    #配列のindexが0にならないように調整
    return(round(log(runif(1)) / log(pexp)) + 1)
  }
  population <- Map(function(x){makerandomtree(pc)},seq(popsize))
  for(i in seq(maxgen)){
    scores <- rankfunction(population)
    cat(scores[[1]][[1]],fill=TRUE)
    if(scores[[1]][[1]] == 0){
      break
    }
    newpop <- c(scores[[1]][[2]],scores[[2]][[2]])
    while(length(newpop) < popsize){
      if(runif(1) > pnew){
        newpop[[length(newpop) + 1]] <- mutate(crossover(scores[[selectindex()]][[2]],
                                scores[[selectindex()]][[2]],
                                probswap=breedingrate),
                      pc,probchange=mutationrate)
      }else{
        newpop[[length(newpop) + 1]] <- makerandomtree(2)
      }
    }
    population <- newpop
  }
  display(scores[[1]][[2]])
  return(scores[[1]][[2]])
}

getrankfunction <- function(dataset){
  rankfunction <- function(population){
    #任意のデータ型を入れられるのは、listのみなので、仕方なくlistでscoreを生成
    s <- c()
    p <- list()
    for(i in seq(length(population))){
      s[i] <- scorefunction(population[i][[1]],dataset)
      p[i] <- population[[i]]
    }
    l <- c()
    n <- 1
    for(i in order(s)){
      l[[n]] <- c(s[i],p[[i]])
      n <- n + 1
    }
    return(l)
  }
  return(rankfunction)
}



rf <- getrankfunction(buidhiddenset())
evolve(2,500,rf)
