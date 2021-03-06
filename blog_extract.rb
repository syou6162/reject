require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'MeCab'
require 'kconv'
require 'csv'
class Blog
  def initialize
  end
  def extract_meisi_from_blog(url)
    list = Array.new
    description = ""
    doc = Hpricot(open(url).read)

    (doc/:item).each {|item|
      description = description + (item/:description).inner_text
    }
    c = MeCab::Tagger.new(%q[-Ochasen]) 
    n = c.parseToNode(description) 

    while n do
      f = n.feature.split(/,/)
      if /名詞/ =~ f[0]
        if /([0-9A-Za-z_ぁ-んァ-ヴ一-龠]){2,}/ =~ n.surface
          list.push(n.surface)
        end
      end
      n = n.next
    end 
  ensure
    return list
  end
  def write_meisi_from_blog(list)
    file = File.open("tmp.csv","w")
    file.puts list
    file.close
  end
  def get_blogs_from_opml()
    opml = "/Users/yasuhisa/Downloads/google-reader-subscriptions.xml"
    doc = Hpricot(open(opml).read)

    blogs = []

    (doc/:outline).each {|item|
      hash = Hash.new
      hash[:title] = item[:title]
      hash[:url] = item[:xmlurl]

      blogs.push hash
    }

    blogs.reject!{|blog| blog[:url].nil?}
    csv = ""
    CSV::Writer.generate(csv,fs="\t") do |writer|
      blogs.each{|blog|
        writer << [blog[:title],blog[:url]]
      }
    end
    return csv
  end
  def write_blogs_from_opml(obj)
    outfile = File.open("tmp.csv","w")
    CSV::Writer.generate(outfile,"\t"){|writer|
      obj.map{|x|x.split("\t")}.each{|item|
        writer << [item[0],item[1].to_s.chomp]
      }
    }
  end
end

