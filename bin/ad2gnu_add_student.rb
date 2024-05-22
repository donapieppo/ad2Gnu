#!/usr/bin/env ruby

require 'pp'
require 'ad2gnu'

new_user = ARGV[0] or raise "Give user's login name (ex nome.cognome) or upn (with @unibo.it) or AD cn (ex Mat033845)"

linuxdsa = AD2Gnu::Base.new(:studenti).AD_login.local_login

user = linuxdsa.ad.get_user(new_user) or raise "Non esiste #{new_user} in AD" 

if linuxdsa.local.exists?(user) 
  puts "Utente già presente in locale"
else
  linuxdsa.local.add_user(user)
end
