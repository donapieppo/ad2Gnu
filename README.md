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

edit configurations for docker: ``docker-compose.yml`` for environment variables and then ``doc/docker_ad2gnu.yml`` and ``doc/docker_ldap.conf``.

```bash
docker-compose build
docker-compose run ad2gnu /bin/bash
``` 

opens a bash on admin host

```bash
ldapsearch -x -H ldap://docker-ldap -b dc=dm,dc=unibo,dc=it -D "cn=admin,dc=dm,dc=unibo,dc=it" -w change_meee 
kinit pietro.donatini@PERSONALE.DIR.UNIBO.IT
ad2gnu_add_user.rb pietro.donatini
```


