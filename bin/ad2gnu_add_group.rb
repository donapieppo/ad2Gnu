#!/usr/bin/env ruby

require 'pp'
require 'ad2gnu'

puts "Give group name"
name = gets.strip
puts "Give description"
description = gets.strip
puts "Give gidNumber"
gidNumber = gets.strip

linuxdsa = AD2Gnu::Base.new().local_login

g = AD2Gnu::Localgroup.new(name, description)
g.gidNumber = gidNumber.to_i

linuxdsa.local.add_group(g)
