#!/usr/bin/ruby -w

require 'pp'
require 'ad2gnu'

utente = ARGV[0] or raise "Dammi login name dell'utente (per ex nome.cognome) oppure il cn (per ex Mat033845)"
attr   = ARGV[1] or raise "Dammi attr da cambiare"
value  = ARGV[2] or raise "Dammi value per #{attr}"

linuxdsa = AD2Gnu::Base.new()

user = linuxdsa.local_login.local.get_user(utente)

#linuxdsa.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'oldDmUserUid', ['donatini'])])
#linuxdsa.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'homeDirectory', ['/export/home/lin'])])
#linuxdsa.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'uidNumber', ['773'])])

puts "MODIFICO in #{user.uid} #{attr} => #{value}"

linuxdsa.local.conn.modify(user.dn,[LDAP.mod(LDAP::LDAP_MOD_REPLACE, attr, [value.to_s])])


