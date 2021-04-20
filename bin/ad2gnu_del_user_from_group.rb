#!/usr/bin/env ruby

require 'pp'
require 'ad2gnu'

uid  = ARGV[0] or raise "Give me uid and group name"
name = ARGV[1] or raise "Give group name"

linuxdsa = AD2Gnu::Base.new().local_login

user  = linuxdsa.local.get_user(uid)
group = linuxdsa.local.get_group(name)

linuxdsa.local.del_user_from_group(user, group)
