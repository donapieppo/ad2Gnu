#!/usr/bin/env ruby

require "ad2gnu"

method = (ARGV[0] > "") ? ARGV[0].to_sym : nil

ad2gnu = AD2Gnu::Base.new(:personale).local_login
ad2gnu.local.each_group do |g| 
  if method
    puts "#{g.cn}: #{g[method]}"
  else
    pp g
  end
end

