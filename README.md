# AD2Gnu
a library (ruby gem) and some scripts to migrate Active Diretory  accounts to openldap accounts.

a library (ruby gem) and some scripts to migrate Active Diretory
accounts to openldap accounts.

## Installation

Add this line to your application's Gemfile:

    gem 'rlinuxdsa'

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


## DOCKER

To try and test the project you can use docker-compose.

The server comes from [https://github.com/osixia/docker-openldap] (if you build 
from scratch remember to add samba.schema).

Edit configurations for docker: ``docker-compose.yml`` for environment variables and then ``doc/docker_ad2gnu.yml`` and ``doc/docker_ldap.conf``.

```bash
docker-compose build
docker-compose run ad2gnu /bin/bash
``` 

opens a bash on admin host

```bash
ldapsearch -x -H ldap://docker-ldap -b dc=dm,dc=unibo,dc=it -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee 
kinit pietro.donatini@PERSONALE.DIR.UNIBO.IT
ad2gnu_add_user.rb pietro.donatini
ldapsearch -x -H ldap://docker-ldap -b dc=dm,dc=unibo,dc=it -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee 
```

In `/etc/ldap/ldap.cond` are configured base and uri.

```bash
ldapsearch -x -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee uid=pietro.donatini
ad2gnu_del_user.rb pietro.donatini
ldapsearch -x -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee uid=pietro.donatini
ad2gnu_add_user.rb pietro.donatini
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
olcAccess: {2}to * by * read by dn="cn=admin,dc=virtlab,dc=unibo,dc=it" write
EOF


