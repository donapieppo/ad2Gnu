#!/usr/bin/env ruby

require "ad2gnu"

group = ARGV[0]
description = ARGV[1]
gid_number = ARGV[2]

(group && description) or raise "Give group name, description and gidNumber"

ad2gnu = AD2Gnu::Base.new.local_login

g = AD2Gnu::LocalGroup.new(group, description)

ad2gnu.local.add_group(g)
