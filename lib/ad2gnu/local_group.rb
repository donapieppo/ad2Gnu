# per ora penso che mentre gli utenti sono presi pari pari da AD
# e quindi il metodo in LocalUser e' from_ldap_res, i gruppi sono
# di nostra manutenzione
module AD2Gnu
class LocalGroup
  attr_accessor :dn, :cn, :name, :description, :memberuids, :gid_number

  alias_method :gidNumber, :gid_number

  def initialize(name, description = nil)
    @name = name
    @description = description
    @memberuids = []
  end

  def self.from_ldap_res(entry)
    group = LocalGroup.new
    group.fill_from_ldap_res(entry)
    group
  end

  def fill_from_ldap_res(entry)
    # questi sempre
    # dn = CN=Mat033845,OU=Str00010,DC=personale,DC=dir,DC=unibo,DC=it
    # cn = Mat033845
    @dn = entry["dn"].first
    @cn = entry["cn"].first
    @name = @cn

    @description = entry["description"].first
    @gid_number = entry["gidNumber"].first
    @memberuids = entry["memberUid"]

    self
  end
end
end
