
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
