#!/usr/bin/env ruby

require "ad2gnu"

method = (ARGV[0].to_s > "") ? ARGV[0].to_sym : nil

ad2gnu_local = AD2Gnu::Base.new.local_login.local

ad2gnu_local.groups.each do |g| 
  if method
    puts "#{g.cn}: #{g.send method}"
  else
    pp g
  end
end

