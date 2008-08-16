
extract_meisi_from_blog <- function(url){
  ruby <- paste("
load %q[/Users/yasuhisa/reject/blog_extract.rb]
blog = Blog.new
blog.write_meisi_from_blog(blog.extract_meisi_from_blog(%q[",url,"]))
",sep="")
  system(paste("echo '",ruby,"'"," | /opt/local/bin/ruby ",sep=""))
  return(scan("tmp.csv",what='character',quiet=TRUE))
}

get_blogs_from_opml <- function(){
  ruby <- paste("
load %q[/Users/yasuhisa/reject/blog_extract.rb]
blog = Blog.new
blog.write_blogs_from_opml(blog.get_blogs_from_opml)
",sep="")
  system(paste("echo '",ruby,"'"," | /opt/local/bin/ruby ",sep=""))
  return(read.csv("tmp.csv",header=FALSE,sep="\t"))
}


if(0){
setClass("classifier",
  representation(
    getfeatures = "character",
    fc      = "numeric",
    cc   = "list"
  )
)


setGeneric("getAge", function(this) standardGeneric("getAge"))
setMethod("getAge", "classifier", function(this) { this@age  })


setGeneric("incf", function(this) standardGeneric("incf"))
setMethod("incf","classifier",function(this){this@fc = this@fc +1;this@fc})
#setMethod("incf","classifier",function(this,f,cat){this@fc$f$cat = this@fc$f$cat +1})

test <- new("classifier", getfeatures="Haruka Amami", fc=list(), cc=list())
incf(test)



getwords <- function(doc){
  unique(strsplit(doc,"\\W")[[1]])
}



incf <- function(list,f,cat){
  

}


hoge <- list(
  python=list(bad=0,good=6),
  the=list(bad=3,good=3)
)

hoge$python$bad


test@getfeatures

}
