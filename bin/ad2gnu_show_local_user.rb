#!/usr/bin/env ruby

require "ad2gnu"

uid = ARGV[0] or raise "dammi upn (ex: pietro.donatini)"

ad2gnu_local = AD2Gnu::Base.new.local_login.local

filter = Net::LDAP::Filter.eq("uid", uid)
ad2gnu_local.conn.search(filter: filter) do |u|
  pp u
end
