# -*- coding: utf-8 -*-
require 'kconv' # toutf8
require 'open-uri'
require 'cgi'
require './formatter.rb'

class Site
  attr_reader :url, :title
  def initialize(url, title)
    @url, @title = url, title
  end

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
 
