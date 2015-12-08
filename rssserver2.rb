# -*- coding: utf-8 -*-
require 'cgi'
require 'open-uri'
require 'rss'
require 'kconv'

class Formatter
  def initialize(site)
    @url = site.url
    @title = site.title
  end
  attr_reader :url, :title
end

class TextFormatter < Formatter
  def format(url_title_time_ary)
    s = "Title: #{title}\n"
    s << "URL: #{url}\n\n"

    url_title_time_ary.each do |url, title, time|
      s << "* (#{time})#{title}\n"
      s << "    #{url}\n"
    end
    s
  end
end

class RSSFormatter < Formatter
  def format(url_title_time_ary)
    RSS::Maker.make("2.0") do |maker|
      maker.channel.updated = Time.now.to_s
      maker.channel.link = url
      maker.channel.title = title
      maker.channel.description = title

      url_title_time_ary.each do |url, title, time|
        maker.items.new_item do |item|
          item.link = url
          item.title = title
          item.updated = time
          item.description = title
        end
      end
    end
  end
end

class Site
  attr_reader :url, :title
  def initialize(url, title)
    @url, @title = url, title
  end

#  attr_reader :url, :title

  def page_source
    @page_source ||= open(@url, &:read).toutf8
  end

  def output(formatter_klass)
    formatter_klass.new(self).format(parse)
  end
end

class SbcrTopics < Site
  def parse
    dates = page_source.scan(%r!(\d+)年 ?(\d+)月 ?(\d+)日<br />!)
    url_titles = page_source.scan(%r!^<a href="(.+?)">(.+?)</a><br />!)

    url_titles.zip(dates).map do |(url, title), ymd|
      [CGI.unescapeHTML(url), CGI.unescapeHTML(title), Time.local(*ymd)]
    end
  end
end

site = SbcrTopics.new("http://crawler.sbcr.jp/samplepage.html", "WWW.SBCR.JP トピックス")

case ARGV.first
when "rss-output"
  puts site.output(RSSFormatter) 
when "text-output"
  puts site.output(TextFormatter)
end


