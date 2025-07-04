#!/usr/bin/env ruby

require "ad2gnu"

name = ARGV[0] or raise "Give login name of local ldap user"

ad2gnu = AD2Gnu::Base.new.local_login

if (group = ad2gnu.local.get_group(name))
  puts "#{name} in local ldap is:"
  pp group
  puts "you want to delete user? CTRL + C to stop"
  $stdin.gets
  ad2gnu.local.delete(group.dn)
else
  puts "utente non trovato"
end
