#!/usr/bin/env ruby

require "ad2gnu"

g = ARGV[0] or raise "Give group name"

ad2gnu = AD2Gnu::Base.new()

filter = Net::LDAP::Filter.eq("cn", g)
ad2gnu.local_login.local.conn.search(filter: filter) do |x|
  pp x
end
