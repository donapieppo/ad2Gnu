module AD2Gnu
class LocalUser
  attr_reader :dn, :cn, :objectclass, :gecos, :uid, :sn, :given_name, :login_shell, :mail, :employee_number, :uid_number, :gid_number, :home_directory, :description, :samba_sid, :title, :ssh_public_keys

  alias_method :givenName, :given_name
  alias_method :loginShell, :login_shell
  alias_method :employeeNumber, :employee_number
  alias_method :uidNumber, :uid_number
  alias_method :gidNumber, :gid_number
  alias_method :homeDirectory, :home_directory
  alias_method :sambaSID, :samba_sid

  def self.from_ldap_res(entry)
    user = LocalUser.new
    user.fill_from_ldap_res(entry)
    user
  end

  def fill_from_ldap_res(entry)
    # questi sempre
    # dn = CN=Mat033845,OU=Str00010,DC=personale,DC=dir,DC=unibo,DC=it
    # cn = Mat033845
    @dn = entry["dn"].first
    @cn = entry["cn"].first

    @gecos = entry["gecos"].first
    @uid = entry["uid"].first
    @cn = entry["cn"].first
    @sn = entry["sn"].first
    @given_name = entry["givenName"].first
    @login_shell = entry["loginShell"].first
    @employee_number = entry["employeeNumber"].first
    @uid_number = entry["uidNumber"].first
    @gid_number = entry["gidNumber"].first
    @home_directory = entry["homeDirectory"].first
    @description = entry["description"].first
    @samba_sid = entry["sambaSID"].first
    @mail = entry["mail"]&.first
    @title = entry["title"]&.first
    @ssh_public_keys = entry["sshPublicKey"]

    self
  end
end
end
