#!/usr/bin/env ruby

require "ad2gnu"

g = ARGV[0] or raise "dammi group"

ad2gnu = AD2Gnu::Base.new

f = Net::LDAP::Filter.eq("cn", g)
ad2gnu.ad_login.ad.conn.search(filter: f) do |ou|
  pp ou
end
