module AD2Gnu
class Base
  attr_reader :ad, :local

  # rad = AD2Gnu::Base.new(domain, logger)
  def initialize(domain = nil)
    @domain = domain
    @conf   = AD2Gnu::Conf.new('/etc/ad2gnu.yml')
    @logger = Logger.new(@conf.debug)
  end

  def AD_login
    @ad = AD.new(@domain, @conf.ad, @logger)
    @conf.groups.each do |k, v|
      @ad.add_group_alias(k, v['ad']) if v['ad']
    end
    self
  end

  def local_login
    @local = Local.new(@conf.ldap, @logger)
    @local.default_gidnumber = @conf.account['gidnumber'] || 10000
    @local.default_homedir   = @conf.account['homedir']   || '/home'
    @conf.groups.each do |k, v|
      @local.add_group_alias(k, v['local']) if v['local']
    end
    self
  end

  def copia_cn(cn)
    e = @ad.leggi_cn(cn)

    # FIXME non sempre esiste description :-(
    displayname = e['displayName'] ? e['displayName'][0] : ''
    description = e['description'] ? e['description'][0] : displayname

    dn = e['distinguishedName'][0]
    @local.verifica_base(dn)

    @logger.log("aggiungo in locale dn=#{dn}, description=#{description}, cn=#{cn}")

    # prendiamo gli objectclass dal cesia gia' che ci siamo 
    # per esempio in CN=PreAccreditati2006 ha top e container
    objectclass = e['objectClass'] or raise "Non recupero objectclass da dn=#{dn}"

    @local.add(dn, { 'objectclass' => objectclass,
                     'description' => [ description ],
                     'cn'          => [ cn ] })

    @logger.log("aggiunta cn=#{cn} (#{description})")
    self
  end

  def copia_ou(ou)
    e = @ad.leggi_ou(ou)

    # FIXME non sempre esiste description :-(
    displayname = e['displayName'] ? e['displayName'][0] : 'Undefined'
    description = e['description'] ? e['description'][0] : displayname

    dn = e['distinguishedName'][0]
    @local.verifica_base(dn)

    @logger.log("aggiungo in locale dn=#{dn}, description=#{description}, ou=#{ou}")

    @local.add(dn, { 'objectclass' => [ 'top', 'organizationalUnit' ],
                     'description' => [ description ],
                     'ou'          => [ ou ] })

    @logger.log("aggiunta ou=#{ou} (#{description})")
    self
  end

end

class Logger
  def initialize(debug, std = nil)
  end

  def log(msg)
    puts "> " + msg
  end
end
end

#
# Copyright (c) Pietro Donatini, 2006.
# 
# this product may be distributed under the terms of
# the GNU Public License.
#
# Librerie per copiare i dati Dsa sull'ldap locale
# 

