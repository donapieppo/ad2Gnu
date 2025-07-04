#!/usr/bin/env ruby

require "ad2gnu"

new_user = ARGV[0] or raise "Give user's login name (ex nome.cognome) or upn (with @unibo.it) or AD cn (ex Mat033845)"
uidNumber = ARGV[1]

ad2gnu = AD2Gnu::Base.new(:personale).ad_login.local_login

user = ad2gnu.ad.get_user(new_user) 
pp user

options = uidNumber ? {uidNumber: uidNumber} : {}
ad2gnu.local.add_user(user, options)
