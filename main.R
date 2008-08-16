setwd("/Users/yasuhisa/reject")
source("./collective.R")

head(read.csv("tmp.csv",sep="\t"))

get_blogs_from_opml()

head(extract_meisi_from_blog("http://d.hatena.ne.jp/syou6162/rss"))

tail(get_blogs_from_opml())$V2

#それぞれのフィードに入っているキーワードの個数のベクトルが入っているリスト
a <- list()

for(url in as.character(get_blogs_from_opml()$V2)[1:20]){
  cat(url,fill=T)
  word <- table(extract_meisi_from_blog(url))
  b <- list(word[order(word,decreasing=TRUE)])
  a <- append(a,b)  
}

#キーワードが全部入っているデータフレームを生成する
hoge <- data.frame(words=I(unique(unlist(mapply(names,a)))))

#blogとキーワードの行列を生成する(本当はデータフレームになっている)
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

summary(hoge)

#単語の登場回数が0なものを列から取り除く
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
