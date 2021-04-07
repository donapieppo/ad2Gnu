# per ora penso che mentre gli utenti sono presi pari pari da AD
# e quindi il metodo in Localuser e' from_ldap_res, i gruppi sono
# di nostra manutenzione
module AD2Gnu
class Localgroup
  attr_accessor :name, :description, :memberuids, :gidNumber

  def initialize(name, description = nil)
    @name        = name
    @description = description
    @memberuids  = Array.new
  end

end
end
