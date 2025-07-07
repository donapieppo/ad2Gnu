#!/usr/bin/env ruby

require "ad2gnu"

group = ARGV[0] or raise "Dammi group"
attr = ARGV[1] or raise "Dammi attr da cambiare"
value = ARGV[2] or raise "Dammi value per #{attr}"

ad2gnu = AD2Gnu::Base.new.local_login

group = ad2gnu.local.get_group(group)

#ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'oldDmUserUid', ['donatini'])])
#ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'homeDirectory', ['/export/home/lin'])])
#ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'uidNumber', ['773'])])

puts "MODIFICO in #{group} #{attr.to_sym} => #{value}"

$stdin.gets

ad2gnu.local.conn.modify(dn: group.dn, operations: [[:replace, attr.to_sym, [value.to_s]]])
