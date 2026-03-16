#!/usr/bin/env ruby

require "ad2gnu"

g = ARGV[0] or raise "Give group name"

ad2gnu = AD2Gnu::Base.new.local_login

pp ad2gnu.local.get_group(g)
