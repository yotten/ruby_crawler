# -*- coding: utf-8 -*-
#require './formatter.rb'
require './site.rb'

site = SbcrTopics.new("http://crawler.sbcr.jp/samplepage.html", "WWW.SBCR.JP トピックス")

case ARGV.first
when "rss-output"
  puts site.output(RSSFormatter) 
when "text-output"
  puts site.output(TextFormatter)
end


