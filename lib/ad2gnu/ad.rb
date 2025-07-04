module AD2Gnu
class AD < Ldap
  attr_reader :base, :conn

  def initialize(domain, conf, logger)
    @domain = domain
    @conf = conf
    @logger = logger

    # usiamo il global catalog a meno di studenti/personale
    # in generale e' chiamato senza domain se non in particolari script che chiedono cose
    # che il global catalog si rifuita di rispondere... mannaggia alui!
    @domain = :gc unless [:studenti, :personale].include?(@domain)
    # tmp per hpc. FIXME
    # TODO
    @domain = :personale

    @conn = Net::LDAP.new(
      host: conf[@domain.to_s]["host"],
      port: conf[@domain.to_s]["port"],
      base: conf[@domain.to_s]["base"],
      auth: {
        method: :simple,
        username: ENV["AD_LDAP_USERNAME"] || conf["username"],
        password: ENV["AD_LDAP_PASSWORD"] || conf["password"]
      },
      encryption: :simple_tls
    )

    @group_aliases = {}
  end

  # add_group('docenti_matematica', "CN=Str00010.Docenti,OU=Str00010,OU=StrDsa.Dip,DC=personale,DC=dir,DC=unibo,DC=it")
  def add_group_alias(name, path)
    @group_aliases[name] = path
  end

  # get_user_by (dovrebbero essere tutti unici, in realta' forse matricola da problemi)
  # get_user_by_upn
  # get_user_by_mail
  # get_user_by_employeeid
  # get_user_by_id
  # get_user_by_cn
  # get_user_by_sam
  %w[upn mail employeeid id cn sam].each do |name|
    define_method :"get_user_by_#{name}" do |q|
      attr, val = case name
      when "upn"
        q !~ /@/ and raise "richiesto upn nome.cognome@..."
        ["userPrincipalName", q]
      when "mail"
        q =~ /@/ or raise "richiesta mail"
        ["mail", q]
      when "employeeid"
        ["employeeID", q.to_i]
      when "id"
        ["extensionAttribute6", q.to_i]
      when "cn"
        ["cn", q]
      when "sam"
        q =~ /@/ and raise "richiesto sAMAccountName e non upn"
        ["sAMAccountName", q]
      end

      f = Net::LDAP::Filter.eq(attr, val) & Net::LDAP::Filter.eq("objectClass", "user")
      search(f) do |u|
        return ADUser.from_ldap_res(u)
      end
    end
  end

  # Shortcut
  # get_user('pietro.donatini') / get_user('pietro.donatini@unibo.it') / get_user('Mat033845')
  def get_user(name)
    if name =~ /^(\w+\.\w+)(@.*)?$/
      if $2 # caso upn
        get_user_by_upn(name)
      else
        get_user_by_sam(name)
      end
    else
      get_user_by_cn(name)
    end
  end

  # users Hash from ou.membri
  def get_users_from_ou(ou_name)
    res = {}

    ou = read_ou(ou_name) or raise "Non trovo #{ou_name}"
    dn = ou["distinguishedName"][0]

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      tmp = ADUser.from_ldap_res(e)
      res[tmp.sAMAccountName] = tmp
    end

    res
  end

  # users Hash from da cn.membri
  def get_users_from_cn(cn_name)
    res = {}

    cn = read_cn(cn_name) or raise "Non trovo #{cn_name}"
    dn = cn["distinguishedName"][0]

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      tmp = ADUser.from_ldap_res(e)
      res[tmp.sAMAccountName] = tmp
    end

    res
  end

  # each_member_from_cn("pippo")
  # each_member_from_cn("pippo", "StudentiAttivi")
  def each_member_from_cn(cn, attr = "Membri")
    cn = read_cn("#{cn}.#{attr}") or raise "Non trovo #{cn}"
    dn = cn["distinguishedName"][0]

    @logger.debug("Found grup #{cn.inspect}\ndn: #{dn}\n")

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      yield(ADUser.from_ldap_res(e))
    end
  end

  # each_member_of("dottorandi_matematica") do |u|
  def each_member_of(group)
    puts "each_member_of memberof=#{@group_aliases[group]}"
    search("memberof=#{@group_aliases[group]}") do |e|
      yield(ADUser.from_ldap_res(e))
    end
  end
end
end

# PERSONALE
# memberOf: CN=Str00810.membri,OU=Str00810,DC=personale,DC=dir,DC=unibo,DC=it
#
# STUDENTI
# dn: CN=Pin0163996,OU=Cdl0099,OU=Fac0016,DC=studenti,DC=dir,DC=unibo,DC=it
# memberOf: CN=Cdl0099.membri,OU=Cdl0099,OU=Fac0016,DC=studenti,DC=dir,DC=unibo,DC=it
# memberOf: CN=Cdl0099.A3,OU=Cdl0099,OU=Fac0016,DC=studenti,DC=dir,DC=unibo,DC=it
# memberOf: CN=Cdl0099.StudentiAttivi,OU=Cdl0099,OU=Fac0016,DC=studenti,DC=dir,DC=unibo,DC=it
#
#
# Copyright (c) Pietro Donatini, 2006 - 2009
#
# this product may be distributed under the terms of
# the GNU Public License.
#
# Librerie per copiare i dati Dsa sull'ldap locale
