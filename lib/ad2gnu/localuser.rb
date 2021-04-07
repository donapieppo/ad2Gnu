module AD2Gnu
class Localuser

  attr_reader :dn, :cn, :objectclass, :gecos, :uid, :sn, :givenName, :loginShell, :mail,
              :employeeNumber, :uidNumber, :gidNumber, :homeDirectory, :description, :sambaSID, :title

  def Localuser.from_ldap_res(entry)
    user = Localuser.new
    user.fill_from_ldap_res(entry)
    user
  end

  def fill_from_ldap_res(entry)
    # questi sempre
    # dn = CN=Mat033845,OU=Str00010,DC=personale,DC=dir,DC=unibo,DC=it
    # cn = Mat033845
    @dn = entry['dn'].first
    @cn = entry['cn'].first

    @gecos          = entry['gecos'].first
    @uid            = entry['uid'].first
    @cn             = entry['cn'].first
    @sn             = entry['sn'].first
    @givenName      = entry['givenName'].first
    @loginShell     = entry['loginShell'].first
    @employeeNumber = entry['employeeNumber'].first
    @uidNumber      = entry['uidNumber'].first
    @gidNumber      = entry['gidNumber'].first
    @homeDirectory  = entry['homeDirectory'].first
    @description    = entry['description'].first
    @sambaSID       = entry['sambaSID'].first
    @mail           = entry['mail'] ? entry['mail'].first : nil
    @title          = entry['title'] ? entry['title'].first : nil
  end


end
end
