module AD2Gnu
class AD < Ldap

  def initialize(domain, conf, logger)
    @conf   = conf
    @logger = logger
    @domain = domain

    # usiamo il global catalog a meno di studenti/personale
    # in generale e' chiamato senza domain se non in particolari script che chiedono cose
    # che il global catalog si rifuita di rispondere... mannaggia alui!
    @domain = :gc unless [:studenti, :personale].include?(@domain)

    @server = conf[@domain.to_s]['host']
    @port   = conf[@domain.to_s]['port']
    @base   = conf[@domain.to_s]['base']

    @conn = LDAP::Conn.new(@server, @port).sasl_bind('','')
    @conn.perror("bind")
    @logger.log("connected with #{@server} on port #{@port}")
  end

  # add_group('docenti_matematica', "CN=Str00010.Docenti,OU=Str00010,OU=StrDsa.Dip,DC=personale,DC=dir,DC=unibo,DC=it")
  def add_group_alias(name, path)
    @group_aliases ||= Hash.new
    @group_aliases[name] = path
  end

  # get_user_by (dovrebbero essere tutti unici, in realta' forse matricola da problemi)
  # get_user_by_upn
  # get_user_by_mail
  # get_user_by_employeeid
  # get_user_by_id
  # get_user_by_cn
  # get_user_by_sam
  %w(upn mail employeeid id cn sam).each do |name|
    define_method "get_user_by_#{name}" do |q|
      query = case name
      when "upn"
        q !~ /@/ and raise "richiesto upn nome.cognome@..."
        "userPrincipalName=#{q}"
      when "mail"
        q =~ /@/ or raise "richiesta mail"
        "mail=#{q}"
      when "employeeid"
        "employeeID=#{q.to_i}"
      when "id"
        "extensionAttribute6=#{q.to_i}"
      when "cn"
        "cn=#{q}"
      when "sam"
        q =~ /@/ and raise "richiesto sAMAccountName e non upn"
        "sAMAccountName=#{q}"
      end
      res = search_array("(&(#{query})(objectClass=user))")
      return ADUser.from_ldap_res(res.first) 
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
  def get_utenti_da_ou(ou_name)
    res = Hash.new

    ou = leggi_ou(ou_name) or raise "Non trovo #{ou_name}"
    dn = cn['distinguishedName'][0]

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      tmp = ADUser.from_ldap_res(e)
      res[tmp.cn] = tmp
    end

    res
  end

  # users Hash from da cn.membri
  def get_utenti_da_cn(cn_name)
    res = Hash.new

    cn = leggi_cn(cn_name) or raise "Non trovo #{cn_name}"
    dn = cn['distinguishedName'][0]

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      tmp = ADUser.from_ldap_res(e)
      res[tmp.cn] = tmp
    end

    res
  end

  # Hash di ADUser da ou.StudentiAttivi (o membri se non funziona...)
  # Hash con kiave user.cn
  def each_personale_di_cn(cn)
    gruppo = leggi_cn("#{cn}.Membri") or raise "Non trovo #{cn}"
    dn     = gruppo['distinguishedName'][0]

    @logger.log("Trovato gruppo: #{gruppo.inspect} e \ndn: #{dn}\n\n")

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      yield(ADUser.from_ldap_res(e))
    end
  end
  
  # Hash di ADUser da ou.StudentiAttivi (o membri se non funziona...)
  # Hash con kiave user.cn
  def each_studente_attivo_di_ou(ou)
    # CN=Cdl1601.069.StudentiAttivi,OU=Cdl1601.069,OU=Fac0016,DC=studenti,DC=dir,DC=unibo,DC=it
    gruppo = leggi_cn("#{ou}.StudentiAttivi") or raise "Non trovo StudentiAttivi in #{ou}"
    dn     = gruppo['distinguishedName'][0]

    @logger.log("Trovato gruppo: #{gruppo.inspect} e \ndn: #{dn}\n\n")

    search("(&(memberOf=#{dn})(objectClass=user))") do |e|
      begin
        yield(ADUser.from_ldap_res(e))
      rescue NoIdAnagraficaUnicaError => e
        puts "NO ID ANAGRAFICA"
        puts e
      end
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
# 

