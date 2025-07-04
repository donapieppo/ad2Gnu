#!/usr/bin/env ruby

require "ad2gnu"

method = (ARGV[0].to_s > "") ? ARGV[0].to_sym : nil

ad2gnu = AD2Gnu::Base.new.local_login
ad2gnu.local.users.each do |u| 
  if method
    puts "#{u.uid}: #{u.send(method.to_sym)}"
  else
    pp u
  end
end

