# -*- coding: utf-8 -*-
#
# ==Site class
#
# Author:: yotten
# Version:: 0.0.1
# License:: Ruby Licence
#
require 'kconv' # toutf8
require 'open-uri'
require 'cgi'
require './formatter.rb'

puts "RUBY_VERSION=#{RUBY_VERSION}"

# @abstract 抽象クラス
class Site
  # @param url [String] URL("http://crawler.sbcr.jp/samplepage.html")
  # @param title [String] Title(WWW.SBCR.JP トピックス")
  # @return [nil]
  def initialize(url, title)
    @url, @title = url, title
  end

  attr_reader :url, :title

  # @return [String]
  def page_source
    @page_source ||= open(@url, &:read).toutf8
  end

  def output(formatter_klass)
puts "formatter_klass=#{formatter_klass}"
    formatter_klass.new(self).format(parse)
  end
end

class SbcrTopics < Site
  # @return [Array] URL,タイトル,時間の配列
  def parse
    dates = page_source.scan(%r!(\d+)年 ?(\d+)月 ?(\d+)日<br />!)
    url_titles = page_source.scan(%r!^<a href="(.+?)">(.+?)</a><br />!)

    url_titles.zip(dates).map do |(url, title), ymd|
      [CGI.unescapeHTML(url), CGI.unescapeHTML(title), Time.local(*ymd)]
    end
  end
end
 
