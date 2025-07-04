module AD2Gnu
class Ldap
  def search(filter)
    @conn.search(filter: filter) do |e|
      yield e
    end
  end

  def search_array(query)
    @conn.search2(@base, LDAP::LDAP_SCOPE_SUBTREE, query)
  end

  # supponendo univoci gli ou restituisce l'Ldap::Entry relativo all'ou
  def read_ou(ou)
    f = Net::LDAP::Filter.eq("ou", ou)
    @conn.search(filter: f) do |e|
      return e
    end
    nil
  end
  alias_method :leggi_ou, :read_ou

  # supponendo univoci i cn restituisce l'Ldap::Entry relativo al cn
  def read_cn(cn)
    f = Net::LDAP::Filter.eq("cn", cn)
    @conn.search(filter: f) do |e|
      return e
    end
    nil
  end
  alias_method :leggi_cn, :read_cn

  def search2(base, query)
    @conn.search(base, LDAP::LDAP_SCOPE_SUBTREE, query) do |e|
      yield e
    end
  end
end
end
