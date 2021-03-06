
get_blogs_from_opml <- function(){
  ruby <- paste("
load %q[/Users/yasuhisa/reject/blog_extract.rb]
blog = Blog.new
blog.write_blogs_from_opml(blog.get_blogs_from_opml)
",sep="")
  system(paste("echo '",ruby,"'"," | /opt/local/bin/ruby ",sep=""))
  d <- read.csv("tmp.csv",header=FALSE,sep="\t",stringsAsFactors=FALSE)
  names(d) <- c("title","url")
  return(d)
}

#blogとキーワードの行列を生成する(本当はデータフレームになっている)
get_data_frame_of_words_from_urls <- function(urls){
  extract_meisi_from_blog <- function(url){
    ruby <- paste("
load %q[/Users/yasuhisa/reject/blog_extract.rb]
blog = Blog.new
blog.write_meisi_from_blog(blog.extract_meisi_from_blog(%q[",url,"]))
",sep="")
    system(paste("echo '",ruby,"'"," | /opt/local/bin/ruby ",sep=""))
    return(scan("tmp.csv",what='character',quiet=TRUE))
  }
  
  #それぞれのフィードに入っているキーワードの個数のベクトルが入っているリスト
  make_lists_of_words_from_urls <- function(urls){
    a <- list()
    for(url in urls){
      cat(url,fill=T)
      word <- table(extract_meisi_from_blog(url))
      b <- list(word[order(word,decreasing=TRUE)])
      a <- append(a,b)  
    }
    return(a)
  }
  
  a <- make_lists_of_words_from_urls(urls$url)
  #Iは因子化を防ぐための操作
  d <- data.frame(words=I(unique(unlist(mapply(names,a)))))


  d <- cbind(d,mapply(function(i){as.numeric(mapply(function(x){ifelse(!is.na(a[[i]][x]),a[[i]][x],0)},d$words))},seq(length(a))))
  #keywordをrow.namesにして、データフレームから出しておく
  row.names(d) <- d$words
  d$words <- NULL
  #colのnameのほうはblogのurlにしておく
  names(d) <- urls$url
  #単語の登場回数が0なものを列から取り除く
  d <- d[,as.vector(apply(d,2,function(x){!all(x == 0)}))]
  return(d)
}

add_frag <- function(urls,flags){
  if(is.null(urls$flag)){
    urls$flag <- 0
  }
  urls$flag <- mapply(function(x){ifelse(urls$url==x,1,0)},flags)
  return(urls)
}

