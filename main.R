setwd("/Users/yasuhisa/reject")
source("./collective.R")

head(read.csv("tmp.csv",sep="\t"))

get_blogs_from_opml()

head(extract_meisi_from_blog("http://d.hatena.ne.jp/syou6162/rss"))

tail(get_blogs_from_opml())$V2



aaa <- get_blogs_from_opml()

str(head(aaa))
str(get_data_frame_of_words_from_urls(get_blogs_from_opml()[1:5,]))





head(hoge,n=3)
summary(hoge)

as.character(get_blogs_from_opml()$V2)[1:20]

hoge$"http://www.6sese.info/wordpress/index.php/feed"
head(hoge[,1:3])

summary(hoge)


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



