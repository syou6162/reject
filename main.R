setwd("/Users/yasuhisa/reject")
source("./collective.R")

urls <- get_blogs_from_opml()
urls
d <- get_data_frame_of_words_from_urls(urls)
cor(d[,1:5])
symnum(cor(d[,1:5]))
str(d)

save




save(d, file = "d.Rdata")


load("d.Rdata")


flags <- c(
"http://dev.chrisryu.com/atom.xml",
"http://b.hatena.ne.jp/kkobayashi/atomfeed?tag=R",
"http://labs.unoh.net/atom.xml",
"http://blog.kzfmix.com/rss/",
"http://feeds.feedburner.com/Asiajin",
"http://feeds.feedburner.com/Clmemoaka",
"http://lifehacking.jp/feed/atom",
"http://www.geekpage.jp/rss.php"
)

apply(add_frag(urls,flags)$flag,1,sum)



