#!/usr/bin/env ruby

require 'pp'
require 'ad2gnu'

user_uid = ARGV[0] or raise "Give login name of local ldap user"

linuxdsa = AD2Gnu::Base.new()
linuxdsa.local_login

if user = linuxdsa.local.get_user(user_uid) 
  puts "#{user_uid} in local ldap is:"
  pp user
  puts "you want to delete user? CTRL + C to stop"
  a = STDIN.gets
  linuxdsa.local.delete(user.dn)
else
  puts "utente non trovato"
end

