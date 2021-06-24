# encoding: utf-8

module AD2Gnu
class Local < Ldap
  attr_reader :base, :conn
  attr_accessor :default_gidnumber, :default_homedir

  def initialize(conf, logger)
    @conf   = conf
    @logger = logger
    @base   = @conf['base']

    @conn = LDAP::Conn.new(@conf['host'])
                      .set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
                      .simple_bind(@conf['admin'], @conf['password'])
    @conn.perror("bind local")
  end

  # add_group_alias('docenti_matematica', "mat-doc")
  def add_group_alias(name, path)
    @group_aliases ||= Hash.new
    @group_aliases[name] = path
  end

  # non ci poniamo problemi e esiste gia' 
  def add(dn, hash)
    begin
      @conn.add(dn, hash)
      @logger.log("Creato #{hash['description']} con dn: #{dn}")
    rescue LDAP::ResultError => error
      if error.message == 'Already exists'
        puts "Already exists"
        return
      end
      raise LDAP::ResultError, "in add con #{dn.inspect} #{hash.inspect}: #{error.inspect}"
    end
  end

  def each_user 
    filter = "(&(uid=*)(objectClass=inetOrgPerson))"
    search_array(filter).each do |u|
      yield u
    end
  end

  # get_user("pietro.donatini")
  def get_user(name)
    filter = "(&(uid=#{name})(objectClass=inetOrgPerson))"
    res = search_array(filter)
    if res.kind_of?(Array) and res.length > 0
      Localuser.from_ldap_res(res[0])
    else
      nil
    end
  end

  def get_dn_from_uid(uid)
    res = @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, "uid=#{uid}", "dn")
    res[0]['dn'][0]
  end

  def get_group(cn)
    filter = "(&(cn=#{cn})(objectClass=posixGroup))"
    res = search_array(filter)
    if res.kind_of?(Array) and res.length > 0
      res[0]
    else
      nil
    end
  end

  # ricorda che il gecos e' solo in caratteri IA5, che consiste di acii
  # http://www.openldap.org/lists/openldap-software/200409/msg00550.html
  # lo prendiamo e lo trasformiamo da 'description' che e' un utf-8
  def add_user(user, options = {})

    # ex cn=Pin0610239
    uid = user.sAMAccountName
    dn  = "uid=#{uid},#{@base}"

    # uidNumber da assegnare e' conservato nell'utente nextuser in dc=linuxdsa. si veda 
    # http://linuxdsa.dm.unibo.it/doku.php?id=struttura_cesia.ldif
    # non usiamo piu' leggi_next_uidNumber perche' mettiamo id anagrafica unica.
    #new_uidNumber = leggi_next_uidNumber
    #new_sidNumber = new_uidNumber * 2 + 1000;

    ###################################
    # ed ecco il succo di tutto !!!!! #
    ###################################
    # a quale DOMINIO KERBEROS (per comodita' di ldap schema uso sambaDomainName) ci dobbiamo
    # l'utente in questione appartiene
    
    sambaDomainName = user.userPrincipalName =~ /\@studio\.unibo\.it/ ? 'STUDENTI.DIR.UNIBO.IT' :
                                                                        'PERSONALE.DIR.UNIBO.IT'

   if ! (user.idAnagraficaUnica or options[:uidNumber])
     raise NoIdAnagraficaUnicaError, "Manca id anagrafica unica a #{user.inspect}"
   end

    # eventualmente 'dsaAccount'
    dati = { 'objectclass'     => [ 'posixAccount', 'shadowAccount', 'inetOrgPerson', 'sambaSamAccount' ],
             'gecos'           => [ gecos_from_description(user.description) ],
             'description'     => [ user.description ],
             'uid'             => [ user.sAMAccountName ],
             'cn'              => [ user.cn ],
             'sn'              => [ user.sn ],
             'givenName'       => [ user.givenName ],
             'loginShell'      => [ '/bin/bash' ],
             'employeeNumber'  => [ user.employeeID ],
             # 'uidNumber'       => [ options[:uidNumber] ? options[:uidNumber].to_s : new_uidNumber.to_s ],
             'uidNumber'       => [ options[:uidNumber] ? options[:uidNumber].to_s : user.idAnagraficaUnica.to_s ],
             'gidNumber'       => [ @default_gidnumber.to_s ],
             'mail'            => [ options[:mail] ? options[:mail] : user.mail ],
             'shadowExpire'    => [ '20000' ],
             'homeDirectory'   => [ options[:homeDirectory] ? options[:homeDirectory] : @default_homedir + "/" + user.sAMAccountName ],
             'sambaDomainName' => [ sambaDomainName ],
             'sambaSID'        => [ Samba.SidToString(user.objectSid) ]
    }

    @logger.log("pronto ad aggiungere #{dn}: #{dati.inspect}")

    add(dn, dati)
  end

  def add_group(group)
    dn = "cn=#{group.name},ou=groups,#{@base}"
    dati = { 'objectclass' => [ 'posixGroup' ],
             'cn'          => [ group.name ],
             'gidNumber'   => [ read_next_gidNumber.to_s ],
             'description' => [ group.description ]
           }
    @logger.log("pronto ad aggiungere #{dn}: #{dati.inspect}")
    add(dn, dati)
  end

  def add_user_to_group(user, group)
    dn = group['dn'].first
    modval = LDAP::Mod.new(LDAP::LDAP_MOD_ADD, 'memberUid', [user.uid])
    @conn.modify(dn, [ modval ])
    @logger.log("aggiunto #{user.uid} to group #{dn}")
  end

  def del_user_from_group(user, group)
    dn = group['dn'].first
    modval = LDAP::Mod.new(LDAP::LDAP_MOD_DELETE, 'memberUid', [user.uid])
    @conn.modify(dn, [ modval ])
    @logger.log("eliminato #{user.uid} to group #{dn}")
  end

  def set_title(user, title)
    modval = LDAP::Mod.new(LDAP::LDAP_MOD_REPLACE, 'title', [title])
    @conn.modify(user.dn, [ modval ])
    user
  end

  # si puo' chiamare con un ADUser o con uid
  def exists?(user)
    begin
      if user.is_a?(ADUser)
        @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, "uid=#{user.sAMAccountName}", ['uid']).size > 0
      elsif user.is_a?(String)
        @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, "uid=#{user}", ['uid']).size > 0
      else
        puts "richiesto #{user.inspect} in formato non corretto"
        return false
      end
    rescue
      return false
    end
  end

  def delete(dn)
    @conn.delete(dn)
  end

  # sperando siano pochi :-)
  def read_next_gidNumber
    last = @conn.search2( "ou=groups,#{@base}", LDAP::LDAP_SCOPE_ONELEVEL, 'cn=*', ['gidNumber'] ).map {|res| res['gidNumber'].first.to_i }.sort.last
    last ? last + 1 : @conf.gidNumber
  end

  def leggi_next_uidNumber
    e = @conn.search2( "dc=linuxdsa,#{@base}", LDAP::LDAP_SCOPE_ONELEVEL, 'cn=nextuser', ['uidNumber'] )
    (e == []) and raise "Manca c=nextuser. Hai installato lo schema linuxdsa?"
    e[0]['uidNumber'][0].to_i
  end

  def update_next_uidNumber 
    number = leggi_next_uidNumber.to_i + 1
    @conn.modify("cn=nextuser,dc=linuxdsa,#{@base}", { 'uidNumber' => [ number.to_s ] } )
    @conn.perror("modify")
  end

  # gecos e' ascii
  def gecos_from_description(str)
    str.force_encoding("UTF-8").gsub(/[àáâãäå]/,'a').gsub(/[èéêë]/,'e').gsub(/[ù]/, 'u').gsub(/[ò]/, 'o').gsub(/’/, "'").gsub('ñ', 'n')
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

