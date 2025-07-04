module AD2Gnu
class Base
  attr_reader :ad, :local

  def initialize(domain = nil, logger = nil, conf_file = "/etc/ad2gnu.yml")
    @domain = domain
    @conf = AD2Gnu::Conf.new(conf_file)
    @logger = logger || Logger.new($stdout)
  end

  def ad_login
    @ad = AD.new(@domain, @conf.ad, @logger)
    @conf.groups.each do |k, v|
      @ad.add_group_alias(k, v["ad"]) if v["ad"]
    end
    self
  end
  alias_method :AD_login, :ad_login

  def local_login
    @local = Local.new(@conf.ldap, @logger)
    @local.default_gidnumber = @conf.account["gidnumber"] || 10000
    @local.default_homedir = @conf.account["homedir"] || "/home"
    @conf.groups.each do |k, v|
      @local.add_group_alias(k, v["local"]) if v["local"]
    end
    self
  end

  def copy_cn(cn)
    e = @ad.leggi_cn(cn)

    # FIXME non sempre esiste description :-(
    displayname = e["displayName"] ? e["displayName"][0] : ""
    description = e["description"] ? e["description"][0] : displayname

    dn = e["distinguishedName"][0]
    @local.verifica_base(dn)

    @logger.debug("Aggiungo in locale dn=#{dn}, description=#{description}, cn=#{cn}")

    # prendiamo gli objectclass dal cesia gia' che ci siamo
    # per esempio in CN=PreAccreditati2006 ha top e container
    objectclass = e["objectClass"] or raise "Non recupero objectclass da dn=#{dn}"

    @local.add(dn, {"objectclass" => objectclass,
                    "description" => [description],
                    "cn" => [cn]})

    @logger.info("Aggiunta cn=#{cn} (#{description})")
    self
  end
  alias_method :copia_cn, :copy_cn

  def copy_ou(ou)
    e = @ad.leggi_ou(ou)

    # FIXME non sempre esiste description :-(
    displayname = e["displayName"] ? e["displayName"][0] : "Undefined"
    description = e["description"] ? e["description"][0] : displayname

    dn = e["distinguishedName"][0]
    @local.verifica_base(dn)

    @logger.debug("Aggiungo in locale dn=#{dn}, description=#{description}, ou=#{ou}")

    @local.add(dn, {"objectclass" => ["top", "organizationalUnit"],
                    "description" => [description],
                    "ou"          => [ou]})

    @logger.info("Aggiunta ou=#{ou} (#{description})")
    self
  end
  alias_method :copia_ou, :copy_ou
end
end

#
# Copyright (c) Pietro Donatini, 2006-2024.
#
# this product may be distributed under the terms of
# the GNU Public License.
#
# Librerie per copiare i dati Dsa sull'ldap locale
