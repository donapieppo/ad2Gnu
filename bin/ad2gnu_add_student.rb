#!/usr/bin/env ruby

require "ad2gnu"

new_user = ARGV[0] or raise "Give user's login name (ex nome.cognome) or upn (with @unibo.it) or AD cn (ex Mat033845)"

ad2gnu = AD2Gnu::Base.new(:studenti).ad_login.local_login

user = ad2gnu.ad.get_user(new_user) or raise "Non esiste #{new_user} in AD" 

ad2gnu.local.add_user(user)

