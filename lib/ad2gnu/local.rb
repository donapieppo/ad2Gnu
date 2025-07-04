module AD2Gnu
class Local < Ldap
  attr_reader :base, :conn
  attr_accessor :default_gidnumber, :default_homedir

  def initialize(conf, logger)
    @conf = conf
    @logger = logger
    @base = conf["base"]

    @conn = Net::LDAP.new(
      host: conf["host"],
      port: conf["port"],
      base: @base,
      auth: {
        method: :simple,
        username: ENV["LOCAL_LDAP_USERNAME"] || conf["username"],
        password: ENV["LOCAL_LDAP_PASSWORD"] || conf["password"]
      },
      encryption: :simple_tls
    )

    @group_aliases = {}
  end

  # add_group_alias('docenti_matematica', "mat-doc")
  def add_group_alias(name, path)
    @group_aliases[name] = path
  end

  # non ci poniamo problemi se esiste già
  def add(dn, hash)
    if @conn.add(dn: dn, attributes: hash)
      @logger.info("Creato #{hash["description"]} con dn: #{dn}")
    else
      e = @conn.get_operation_result
      if e.message == "Entry Already Exists"
        puts "Entry Already Exists"
      else
        raise AD2Gnu::ResultError, "Local: add with #{dn.inspect} #{hash.inspect}: #{e.inspect}"
      end
    end
  end

  def users
    f = Net::LDAP::Filter.eq("uid", "*") & Net::LDAP::Filter.eq("objectClass", "inetOrgPerson")
    @conn.search(filter: f).map { |ldap_user| LocalUser.new.fill_from_ldap_res(ldap_user) }
  end

  def groups
    f = Net::LDAP::Filter.eq("cn", "*") & Net::LDAP::Filter.eq("objectClass", "posixGroup")
    @conn.search(filter: f).map { |ldap_group| LocalGroup.new(ldap_group["cn"].first).fill_from_ldap_res(ldap_group) }
  end

  # get_user("pietro.donatini")
  # get_user("pietro.donatini@pippo") (the lib does gsub(/@.*/, "")
  def get_user(name)
    name = name.gsub(/@.*/, "")
    f = Net::LDAP::Filter.eq("uid", name) & Net::LDAP::Filter.eq("objectClass", "inetOrgPerson")
    if (u = @conn.search(filter: f).first)
      LocalUser.new.fill_from_ldap_res(u)
    end
  end

  def get_user_by_id(id)
    f = Net::LDAP::Filter.eq("uidNumber", id) & Net::LDAP::Filter.eq("objectClass", "inetOrgPerson")
    # iterate but return first
    if (u = @conn.search(filter: f).first)
      LocalUser.new.fill_from_ldap_res(u)
    end
  end

  def get_dn_from_uid(uid)
    f = Net::LDAP::Filter.eq("uid", uid) & Net::LDAP::Filter.eq("objectClass", "inetOrgPerson")
    if (u = @conn.search(filter: f).first)
      u["dn"][0]
    end
  end

  def get_dn_from_uidNumber(uid_number)
    f = Net::LDAP::Filter.eq("uidNumber", uid_number) & Net::LDAP::Filter.eq("objectClass", "inetOrgPerson")
    if (u = @conn.search(filter: f).first)
      u["dn"][0]
    end
  end

  def get_group(cn)
    f = Net::LDAP::Filter.eq("cn", cn) & Net::LDAP::Filter.eq("objectClass", "posixGroup")
    if (g = @conn.search(filter: f).first)
      LocalGroup.new(cn).fill_from_ldap_res(g)
    end
  end

  def get_user_groups(uid)
    f = Net::LDAP::Filter.eq("memberUid", uid) & Net::LDAP::Filter.eq("objectClass", "posixGroup")
    @conn.search(filter: f).map do |g|
      LocalGroup.new(g.cn).fill_from_ldap_res(g)
    end
  end

  def check_user_in_group(user, group)
    group.memberuids.include? user.uid
  end

  # si puo' chiamare con un ADUser o con uid
  def exists?(user)
    f = case user
    when ADUser
      Net::LDAP::Filter.eq("uid", user.sam_account_name)
    when String
      Net::LDAP::Filter.eq("uid", user)
    else
      puts "richiesto #{user.inspect} in formato non corretto"
      return false
    end
    !@conn.search(filter: f, attributes: ["uid"]).empty?
  end

  # ricorda che il gecos e' solo in caratteri IA5, che consiste di acii
  # http://www.openldap.org/lists/openldap-software/200409/msg00550.html
  # lo prendiamo e lo trasformiamo da 'description' che e' un utf-8
  def add_user(user, options = {})
    # ex cn=Pin0610239
    uid = user.sam_account_name
    dn = "uid=#{uid},#{@base}"

    # uidNumber da assegnare e' conservato nell'utente nextuser in dc=linuxdsa. si veda
    # http://linuxdsa.dm.unibo.it/doku.php?id=struttura_cesia.ldif
    # non usiamo piu' leggi_next_uidNumber perche' mettiamo id anagrafica unica.
    # new_uidNumber = leggi_next_uidNumber
    # new_sidNumber = new_uidNumber * 2 + 1000;

    ###################################
    # ed ecco il succo di tutto !!!!! #
    ###################################
    # a quale DOMINIO KERBEROS (per comodita' di ldap schema uso sambaDomainName) ci dobbiamo
    # l'utente in questione appartiene

    samba_domain_name = (user.upn =~ /@studio\.unibo\.it/) ? "STUDENTI.DIR.UNIBO.IT" : "PERSONALE.DIR.UNIBO.IT"

    if !(user.id_anagrafica_unica || options[:uid_number])
      raise NoIdAnagraficaUnicaError, "Manca id anagrafica unica a #{user.inspect}"
    end

    # eventualmente 'dsaAccount'
    dati = {
      objectclass: ["posixAccount", "shadowAccount", "inetOrgPerson", "sambaSamAccount", "ldapPublicKey"],
      gecos: [gecos_from_description(user.description)],
      description: [user.description],
      uid: [user.sam_account_name],
      cn: [user.cn],
      sn: [user.sn],
      givenName: [user.given_name],
      loginShell: ["/bin/bash"],
      uidNumber: [options[:uid_number] ? options[:uid_number].to_s : user.id_anagrafica_unica.to_s],
      gidNumber: [@default_gidnumber.to_s],
      mail: [options[:mail] || user.mail],
      shadowExpire: ["90000"],
      homeDirectory: [options[:home_directory] || (@default_homedir + "/" + user.sam_account_name)],
      sambaDomainName: [samba_domain_name],
      sambaSID: [Samba.SidToString(user.object_sid)]
    }

    dati["employeeNumber"] = [user.employeeID] unless user.employeeID == ""

    @logger.debug("Pronto ad aggiungere #{dn}: #{dati.inspect}")
    add(dn, dati)
  end

  # is not a syncronize_in_ldap because groups are
  # only local
  def add_group(local_group)
    dn = "cn=#{local_group.name},ou=groups,#{@base}"
    if !local_group.gidNumber
      local_group.gidNumber = read_next_gidNumber
    end
    data = {
      "objectclass" => ["posixGroup"],
      "cn" => [local_group.name],
      "gidNumber" => [local_group.gidNumber.to_s],
      "description" => [local_group.description]
    }
    @logger.debug("Redy to create #{dn}: #{data.inspect}")
    add(dn, data)
  end

  def update_group(local_group)
    dn = "cn=#{local_group.name},ou=groups,#{@base}"
    ops = [
      [:replace, :description, local_group.description]
    ]
    @logger.debug("Ready to update #{dn}: #{ops.inspect}")
    if !@conn.modify(dn: dn, operations: ops)
      @logger.info(@conn.get_operation_result)
    end
  end

  # TODO check presence
  def add_user_to_group(user, group)
    dn = group.dn
    ops = [[:add, :memberUid, [user.uid]]]
    @conn.modify(dn: dn, operations: ops)
    @logger.info("Aggiunto #{user.uid} to group #{dn}")
  end

  def del_user_from_group(user, group)
    @logger.debug("del_user_from_group #{user.inspect}, #{group.inspect}")
    ops = [
      [:delete, :memberUid, [user.uid]]
    ]
    @conn.modify(dn: group.dn, operations: ops)
    @logger.info("Eliminato #{user.uid} to group #{group.dn}")
  end

  def del_user(user)
    delete(user.dn)
  end

  def del_group(group)
    dn = "cn=#{group.name},ou=groups,#{@base}"
    delete(dn)
  end

  def set_title(user, title)
    ops = [[:replace, :title, [title]]]
    @conn.modify(dn: user.dn, operations: ops)
    user
  end

  def delete(dn)
    @conn.delete dn: dn
  end

  # sperando siano pochi :-)
  def read_next_gidNumber
    filter = Net::LDAP::Filter.eq("objectClass", "posixGroup")
    last = @conn.search(filter: filter).map { |res| res["gidNumber"].first.to_i }.max
    last ? last + 1 : default_gidnumber
  end

  def leggi_next_uidNumber
    e = @conn.search2("dc=linuxdsa,#{@base}", LDAP::LDAP_SCOPE_ONELEVEL, "cn=nextuser", ["uidNumber"])
    (e == []) and raise "Manca c=nextuser. Hai installato lo schema linuxdsa?"
    e[0]["uidNumber"][0].to_i
  end

  def update_next_uidNumber
    number = leggi_next_uidNumber.to_i + 1
    @conn.modify("cn=nextuser,dc=linuxdsa,#{@base}", {uidNumber: [number.to_s]})
    @conn.perror("modify")
  end

  # gecos e' ascii
  def gecos_from_description(str)
    str.force_encoding("UTF-8").gsub(/[àáâãäå]/, "a").gsub(/[èéêë]/, "e").gsub(/[ù]/, "u").gsub(/[ò]/, "o").gsub(/’/, "'").tr("ñ", "n")
  end
end
end

# Copyright (c) Pietro Donatini, 2006-2024.
#
# this product may be distributed under the terms of
# the GNU Public License.
#
# Library to copy AD users to Gnu Ldap
