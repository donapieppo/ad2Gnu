#!/usr/bin/env ruby

require 'pp'
require 'ad2gnu'

new_user = ARGV[0] or raise "Give user's login name (ex nome.cognome) or upn (with @unibo.it) or AD cn (ex Mat033845)"
uidNumber = ARGV[1]

linuxdsa = AD2Gnu::Base.new(:personale).AD_login.local_login

user = linuxdsa.ad.get_user(new_user) 

if linuxdsa.local.exists?(user) 
  puts "Utente gia' presente in locale"
else
  options = uidNumber ? { :uidNumber => uidNumber } : {}
  linuxdsa.local.add_user(user, options )
end
