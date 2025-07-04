#!/usr/bin/env ruby

require "ad2gnu"

uid = ARGV[0] or raise "dammi upn (ex: pietro.donatini)"

ad2gnu = AD2Gnu::Base.new()

filter = Net::LDAP::Filter.eq("uid", uid)
ad2gnu.local_login.local.conn.search(filter: filter) do |u|
  pp u
end
