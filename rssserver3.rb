#!/home/pi/.rbenv/shims/ruby
# -*- coding: utf-8 -*-
#require './formatter.rb'
require 'optparse' 
require './site.rb'
require 'webrick'

OPTS = {}

OptionParser.new do |opt|
  begin
    opt.program_name = File.basename($0)
    opt.version = '0.0.1'

    opt.banner = "Usage: #{opt.program_name} [options]" 
#    opt.separator '' 
    opt.on('-s', "server start") {|v| OPTS[:s] = v}
    opt.on('-r', "rss format") {|v| OPTS[:r] = v}
    opt.on('-t', "text format") {|v| OPTS[:t] = v}

    opt.parse!(ARGV)
  rescue => e 
  end
end

class RSSServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(req, res)
    klass = @options[0]
    url = @options[1] 
    title = @options[2]

    kklass, opts = @options 
    res.body = klass.new(url, title).output(RSSFormatter).to_s
    res.content_type = "application/xml; charset=utf-8"
  end
end

def start_server(config = {})
#  srv = WEBrick::HTTPServer.new(:BindAddress => '0.0.0.0', :Port => 80,
#                                                      :CGIInterpreter => $ruby)
  conf = {
    :BindAddress => '0.0.0.0',
    :Port => 80,
    :CGInterpreter => $ruby,
  }
  config.update(conf)
  srv = WEBrick::HTTPServer.new(config)
  yield srv if block_given?
#  cgi_dir = File.dirname(File.expand_path(__FILE__))
#  srv.mount("/", WEBrick::HTTPServlet::FileHandler, cgi_dir,
#                                                        {:FancyIndexing=>true}) 

#  srv.mount('/rss.xml', RSSServlet, SbcrTopics,
#                                      "http://crawler.sbcr.jp/samplepage.html",
#                                                      "WWW.SBCR.JP トピックス")

  trap(:INT) { srv.shutdown }
  srv.start
end

rrr = WEBrick::HTTPServlet::CGIHandler::Ruby
$ruby = $ruby || rrr

module WEBrick
  module HTTPServlet
    FileHandler.add_handler("rb", CGIHandler)
  end
end
if OPTS[:s]
  puts "start_server!"
  start_server { |server|
    cgi_dir = File.dirname(File.expand_path(__FILE__))
    server.mount("/", WEBrick::HTTPServlet::FileHandler, cgi_dir,
                                                        {:FancyIndexing=>true})
    server.mount('/rss.xml', RSSServlet, SbcrTopics,
                                      "http://crawler.sbcr.jp/samplepage.html",
                                                      "WWW.SBCR.JP トピックス") 
  }
else
  puts "not start_server"
#  site = SbcrTopics.new(url:"http://crawler.sbcr.jp/samplepage.html",
#                                                     title:"WWW.SBCR.JP >トピックス")
  site = SbcrTopics.new("http://crawler.sbcr.jp/samplepage.html",
                                                     "WWW.SBCR.JP >トピックス")
  puts site.output(RSSFormatter) if OPTS[:r]
  puts site.output(TextFormatter) if OPTS[:t]
end

