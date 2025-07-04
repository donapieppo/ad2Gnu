#!/usr/bin/env ruby

require "ad2gnu"

utente = ARGV[0] or raise "Dammi login name dell'utente (per ex nome.cognome) oppure il cn (per ex Mat033845)"
attr   = ARGV[1] or raise "Dammi attr da cambiare"
value  = ARGV[2] or raise "Dammi value per #{attr}"

ad2gnu = AD2Gnu::Base.new

user = ad2gnu.local_login.local.get_user(utente)

#ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'oldDmUserUid', ['donatini'])])
#ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'homeDirectory', ['/export/home/lin'])])
#ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'uidNumber', ['773'])])

puts "MODIFICO in #{user.uid} #{attr} => #{value}"

ad2gnu.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, attr, [value.to_s])])
