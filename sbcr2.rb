# -*- coding: utf-8 -*-
require 'cgi'

def parse(page_source)
  dates = page_source.scan(%r!(\d+)年 ?(\d+)月 ?(\d+)日<br />!)
  url_titles = page_source.scan(%r!^<a href="(.+?)">(.+?)</a><br />!)

  url_titles.zip(dates).map do |(url, title), ymd|
    [CGI.unescapeHTML(url), CGI.unescapeHTML(title), Time.local(*ymd)]
  end 
end

def format_text(title, url, url_title_time_ary)
  s = "Title: #{title}\n"
  s << "URL: #{url}\n\n"

  url_title_time_ary.each do |url, title, time|
    s << "* (#{time})#{title}\n"
    s << "    #{url}\n" 
  end
  s
end

puts format_text("WWW.SBCR.JP トピックス", "http://crawler.sbcr.jp/samplepage.html", parse(`wget -q -O- http://crawler.sbcr.jp/samplepage.html`))
