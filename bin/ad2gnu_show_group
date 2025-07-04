#!/usr/bin/env ruby

require "ad2gnu"

g = ARGV[0] or raise "dammi group"

ad2gnu = AD2Gnu::Base.new()

f = Net::LDAP::Filter.eq("ou", g)
ad2gnu.AD_login.ad.conn.search(filter: f) do |ou|
  pp ou
end
