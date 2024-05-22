#!/usr/bin/env ruby

require "ad2gnu"

linuxdsa = AD2Gnu::Base.new()

local = linuxdsa.local_login.local
u = local.get_user("pietro.donatini")
ops = [[:replace, :sshPublicKey, ["poepeope", "plu"]]]
local.conn.modify(dn: u.dn, operations: ops)

