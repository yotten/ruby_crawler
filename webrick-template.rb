#!/usr/bin/ruby

require 'webrick'

server = WEBrick::HTTPServer.new( {:DocumentRoot => ".", :BindAddress => '0.0.0.0', :Port => 80})
trap(:INT){server.shutdown}
server.start

