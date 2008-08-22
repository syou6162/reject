
setClass("fwrapper", representation(f="function", childcount="numeric",name="character"))

setClass("node", representation(fw="fwrapper", children = "list"))
setGeneric("evaluate.node", function(this,inp) standardGeneric("evaluate.node"))
setMethod("evaluate","node",function(this,inp){
  result <- unlist(Map(function(x){evaluate(x,inp)},this@children),recursive=FALSE)
  return(this@fw@f(result))
})

setClass("paramnode", representation(idx = "numeric"))
setGeneric("evaluate.paramnode",function(this,inp){
  standardGeneric("evaluate.paramnode")
})
setMethod("evaluate","paramnode",function(this,inp){
  return(inp[this@idx])
})

setClass("constnode", representation(v = "numeric"))
setGeneric("evaluate.constnode",function(this,inp){
  standardGeneric("evaluate.constnode")
})
setMethod("evaluate",signature(this="constnode"),function(this,inp){
  return(this@v)
})

addw <- new("fwrapper",f=function(x){return(x[1]+x[2])},childcount=2,name="add")
subw <- new("fwrapper",f=function(x){return(x[1]-x[2])},childcount=2,name="subtract")
mulw <- new("fwrapper",f=function(x){return(x[1]*x[2])},childcount=2,name="multiply")

ifw <- new("fwrapper",f=function(x){
  return(ifelse(x[1] > 0,x[2],x[3]))
},childcount=3,name="if")

gtw <- new("fwrapper",f=function(x){
  return(ifelse(x[1] > x[2],1,0))
},childcount=2,name="isgreater")

flist <- c(addw,mulw,subw,ifw,isgreater)

exampletree <- function(){
  return(new("node",fw=ifw,
             children=c(
               new("node",fw=gtw,children=c(
                                   new("paramnode",idx=1),new("constnode",v=3)
                                   )),
               new("node",fw=addw,children=c(
                                    new("paramnode",idx=2),new("constnode",v=5)
                                    )),
               new("node",fw=subw,children=c(
                                    new("paramnode",idx=2),new("constnode",v=2)
                                    ))
               )
             ))
}

exampletree()

evaluate(exampletree(),c(5,3))





