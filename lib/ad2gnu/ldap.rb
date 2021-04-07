module AD2Gnu
class Ldap

  def search(query)
    @conn.search(@base, LDAP::LDAP_SCOPE_SUBTREE, query) do |e|
      yield e
    end
  end

  def search_array(query)
    @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, query)
  end

  # supponendo univoci gli ou restituisce l'Ldap::Entry relativo all'ou 
  def leggi_ou(ou)
	  res = @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, "ou=#{ou}")
    res[0]
  end

  # supponendo univoci i cn restituisce l'Ldap::Entry relativo al cn
  def leggi_cn(cn)
    res = @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, "cn=#{cn}")
    res[0]
  end

  def search2(base, query)
    @conn.search(base, LDAP::LDAP_SCOPE_SUBTREE, query) do |e|
      yield e
    end
  end

end
end

