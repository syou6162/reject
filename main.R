
setwd("/Users/yasuhisa/reject")
source("./collective.R")


get_blogs_from_opml()

extract_meisi_from_blog("http://d.hatena.ne.jp/syou6162/rss2")

tail(get_blogs_from_opml())



a <- list()

for(url in as.character(get_blogs_from_opml()$V2)[1:20]){
  cat(url,fill=T)
  word <- table(extract_meisi_from_blog(url))
  b <- list(word[order(word,decreasing=TRUE)])
  a <- append(a,b)  
}

hoge <- data.frame(words=I(unique(unlist(mapply(names,a)))))

for(i in seq(length(a))){
  hoge[,i+1] <- as.numeric(mapply(function(x){ifelse(!is.na(a[[i]][x]),a[[i]][x],0)},hoge$words))
}

head(hoge,n=30)
summary(hoge)

#keywordをrow.namesにして、データフレームから出しておく
row.names(hoge) <- hoge$words
hoge$words <- NULL

#colのnameのほうはblogのurlにしておく
names(hoge) <- as.character(get_blogs_from_opml()$V2)[1:20]
as.character(get_blogs_from_opml()$V2)[1:20]


hoge$"http://www.6sese.info/wordpress/index.php/feed"
head(hoge[,1:3])


hoge <- hoge[,as.vector(apply(hoge,2,function(x){!all(x == 0)}))]

names(hoge)
names(hoge) <- NULL
str(hoge)
null>(NULL)
apply(hoge,2,function(x){all(is.na(x))})
symnum
hoge[,1:13]
cor(hoge[,1:13])


symnum(cor(hoge[,1:13]))
row.names(hoge)
tail(sort(hoge[,1]))

summary(hoge[,1])
summary(hoge[,8])



python <- "
print 123
"

system(paste("echo '",python,"'"," | python ",sep=""),intern=TRUE)


http://feeds.feedburner.jp/shebang
http://www.akiyan.com/blog/




glob2rx("abc.*")






getwords("hoge hoge fuga")





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






