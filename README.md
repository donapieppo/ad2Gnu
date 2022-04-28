# AD2Gnu
a library (ruby gem) and some scripts to copy Active Diretory accounts to openldap accounts.

## Why

With large AD installation (a campus for example) ad2gnu permit to 
provide a smaller set of accounts via openldap.

  - the account in openldap is a copy of AD account
  - the account in openldap does not have a password but the authetication can be provided by kerberos pam module
  - the account in openldap permits a single uidNumber/gidNumber for user

## Working example with Docker

To try and test the project you can use docker-compose.

Create tls certs in `./docker/etc/certs`.
On clients you need only ca.crt.

```bash
cd ./docker/etc/certs

openssl dhparam -out dhparam.pem 2048

openssl req -subj "/C=IT/ST=Italy/L=Bologna/O=Dipartimento di Matematica/OU=Certification Authority/CN=CA dm.unibo.it/emailAddress=dipmat-supportoweb@unibo.it" -days 4000 -new -newkey rsa:2048 -sha1 -x509 -keyout ca.key -out ca.crt

openssl x509 -noout -text -in ca.crt

openssl req -nodes -new -newkey rsa:2048 -out ldap1.csr -keyout ldap1.key -subj "/C=IT/ST=Italy/L=Bologna/O=Dipartimento di Matematica/OU=Ldap Servers/CN=ldap1.dm.unibo.it/emailAddress=dipmat-supportoweb@unibo.it"

openssl x509 -req -in ldap1.csr -out ldap1.cert -CA ca.crt -CAkey ca.key -CAcreateserial -days 4000
```

The server comes from [https://github.com/osixia/docker-openldap] (if you build 
from scratch remember to add samba.schema).

Edit configurations: ``docker-compose.yml`` for environment variables and then ``doc/docker_ad2gnu.yml`` and ``doc/docker_ldap.conf``.
Then:

```bash
docker-compose build
docker-compose run ad2gnu /bin/bash
``` 
opens a bash on a debian system that allows to create accounts.
In `/etc/ldap/ldap.conf` are configured base and uri.

```bash
ldapsearch -x -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee 
kinit pietro.donatini@PERSONALE.DIR.UNIBO.IT
ad2gnu_add_user.rb pietro.donatini
# search pietro.donatini
ldapsearch -x -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee uid=pietro.donatini
# delete pietro.donatini
ad2gnu_del_user.rb pietro.donatini
# search pietro.donatini
ldapsearch -x -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee uid=pietro.donatini
# add pietro.donatini again
ad2gnu_add_user.rb pietro.donatini
ldapsearch -x -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee uid=pietro.donatini
```
To make changes on slapd server you can connect with 

```bash
docker exec -i -t openldap /bin/bash
```

Since ad2gnu provides just a cache of alredy public 
data you can permit all to make a ldapsearch by changing olcAccess on the server.
For example

```bash
ldapmodify -Y EXTERNAL -H ldapi:/// <<EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {2}to * by * read by dn="cn=admin,dc=dm,dc=unibo,dc=it" write
EOF
```

## CLIENTS

Just a reminder.

To add a client to ad2gnu authentication you can use libnss-ldapd 
(Name Service Switch module that allows using an LDAP server to provide user account, 
group and  basically any other information that would normally be retrieved from /etc)
and then configure the system to use ldap changing /etc/nsswitch.conf.

```bash
apt-get update
apt-get install openldap-utils libnss-ldapd libpam-krb5 krb5-user

cat > /etc/ldap/ldap.conf <<EOF
BASE            dc=dm,dc=unibo,dc=it
URI             ldap://docker-ldap
TLS_CACERT	/etc/ssl/certs/ca-certificates.crt
EOF

cat > /etc/nslcd.conf <<EOF
uid nslcd
gid nslcd

uri  ldap://docker-ldap
base dc=dm,dc=unibo,dc=it
EOF

cat > /etc/nsswitch.conf <<EOF
passwd:         files ldap
group:          files ldap
shadow:         files ldap
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
EOF

/etc/init.d/nslcd restart
```

And then, dadadadada, 

```bash
id pietro.donatini
getent passwd pietro.donatini
```

### Upn / SamAccountName

A big problem with thos approach is that some users will
try to login with upn (name.surname@unibo.it) 
and not with SamAccountName (name.surname).

And worst, sometimes the SamAccountName for name.surname@unibo.it
can be name.surname32@PERSONALE.DIR.UNIBO.IT.


The module [https://github.com/donapieppo/libpam_upn2sam] can mitigate
the problem when the first part of upn and SAM are the same. It is
a pam module that strips the domain from the upn when theuser try to login.

## Installation

Add this line to your application's Gemfile:

    gem 'ad2gnu'

And then execute:

    $ bundle

## Configuration

Edit /etc/ad2gnu.yml file. You find an example in doc directory.

* ldap: informations for local ldap server connections
  * base
  * admin
  * password
* ad: informations for AD servers connections
  * gc is global catalog
  * realm_name indormation used to connect to particular AD domains
* account: local users in local ldap server

## Simple Usage



