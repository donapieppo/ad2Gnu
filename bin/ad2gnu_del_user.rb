#!/usr/bin/env ruby

require "ad2gnu"

uid = ARGV[0] or raise "Give login name of local ldap user"

ad2gnu = AD2Gnu::Base.new.local_login
user = ad2gnu.local.get_user(uid)

if !user
  puts "utente non trovato"
  exit 1
end

groups = ad2gnu.local.get_user_groups(uid)

puts "#{uid} in local ldap is:"
pp user
groups.each do |g|
  puts "APPARTIERE a #{g.inspect}"
end

puts "you want to delete user? CTRL + C to stop"
$stdin.gets

groups.each do |g|
  ad2gnu.local.del_user_from_group(user, g)
end
ad2gnu.local.delete(user.dn)
