#!/usr/bin/env ruby

require "ad2gnu"

uid = ARGV[0]
key = ARGV[1]

ad2gnu = AD2Gnu::Base.new.local_login

user = ad2gnu.local.get_user(uid)

# ops = [[:replace, :sshPublicKey, [, "plu"]]]
ops = [[:add, :sshPublicKey, key]]
ad2gnu.local.conn.modify(dn: user.dn, operations: ops)

