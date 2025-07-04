#!/usr/bin/env ruby

require "ad2gnu"

uid  = ARGV[0] or raise "Give me user uid"
name = ARGV[1] or raise "Give group name"

ad2gnu = AD2Gnu::Base.new.local_login

user  = ad2gnu.local.get_user(uid)
group = ad2gnu.local.get_group(name)

p user
p group

ad2gnu.local.add_user_to_group(user, group)
