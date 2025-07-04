module AD2Gnu
class ADUser
  attr_accessor :dn, :cn, :sam_account_name, :sn, :given_name, :employee_id, :upn, :mail, :description, :title, :object_sid, :id_anagrafica_unica

  alias_method :sAMAccountName, :sam_account_name
  alias_method :givenName, :given_name
  alias_method :employeeID, :employee_id
  alias_method :userPrincipalName, :upn
  alias_method :objectSid, :object_sid
  alias_method :idAnagraficaUnica, :id_anagrafica_unica

  def self.from_ldap_res(entry)
    entry or return nil
    user = ADUser.new
    user.fill_from_ldap_res(entry)
    user
  end

  def name
    @givenName
  end

  def fill_from_ldap_res(entry)
    # questi sempre
    # dn = CN=Mat033845,OU=Str00010,DC=personale,DC=dir,DC=unibo,DC=it
    # cn = Mat033845
    @dn = entry["distinguishedName"][0]
    @cn = entry["cn"][0]

    @sam_account_name = entry["sAMAccountName"].first
    @sn = entry["sn"] ? entry["sn"].first.force_encoding("UTF-8") : " "
    @given_name = entry["givenName"] ? entry["givenName"].first.force_encoding("UTF-8") : ""
    # 33845 ma non esiste per assegnisti etc etc
    @employee_id = entry["employeeID"] ? entry["employeeID"].first.to_s : "0"
    # per i preaccreditati può non esistere
    @mail = entry["mail"] ? entry["mail"].first&.force_encoding("UTF-8") : ""
    @title = entry["title"] ? entry["title"][0] : ""    # studente / Cat. D... /
    @upn = entry["userPrincipalName"][0]  # pietro.donatini@personale.dir.unibo.it
    @object_sid = entry["objectSid"][0]
    @id_anagrafica_unica = entry["extensionAttribute6"] ? entry["extensionAttribute6"][0] : nil

    # description non esiste in studenti MAH
    # ci mettiamo il title nel caso :-)
    @description = entry["description"] ? entry["description"].first.force_encoding("UTF-8") : @title # Dott. Pietro Donatini

    # dai gruppi a cui appartiene l'utente peschiamo qualche informazione
    # per esempio se studenti l'appartenenza al gruppo Cdl*.A3 indica che è al terzo
    # anno di iscrizione... sucks na fuziona...
    # foreach my $group ( $entry->get_value('memberOf') ) {
    #            $group =~ /^CN=Cdl.*?.A(\d),/ or next;
    #            $user->{'annoIscrizione'} = $1;
    #            last;
    #    }
  end
end
end
