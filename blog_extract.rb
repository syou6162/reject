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
    description = ""

    begin
      doc = Hpricot(open(url).read)
    rescue => ex
      exit
    end

    (doc/:item).each {|item|
      description = description + (item/:description).inner_text
    }

    begin 
      c = MeCab::Tagger.new(%q[-Ochasen]) 
      n = c.parseToNode(description) 

      list = Array.new
      while n do
        f = n.feature.split(/,/)
        if /名詞/ =~ f[0]
          if /([0-9A-Za-z_ぁ-んァ-ヴ一-龠]){2,}/ =~ n.surface
            list.push(n.surface)
          end
        end
        n = n.next
      end 
    rescue
      exit
    end
    return list
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
    CSV::Writer.generate(csv,fs="\t",rs="\n") do |writer|
      blogs.each{|blog|
        writer << [blog[:title],blog[:url]]
      }
    end
    return csv
  end
  def write_blogs_from_opml(csv)
    outfile = File.open("tmp.csv","w")
    CSV::Writer.generate(outfile,"\t"){|writer|
      csv.split("\n").map{|x|x.split("\t")}.each{|item|
        writer << [item[0],item[1]]
      }
    }
  end
end
