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

