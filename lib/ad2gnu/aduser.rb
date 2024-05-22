module AD2Gnu
class ADUser
  attr_accessor :dn, :cn, :sAMAccountName, :sn, :givenName, :employeeID, :userPrincipalName, :mail, :description, :title, :objectSid, :idAnagraficaUnica

  def self.from_ldap_res(entry)
    entry or return nil
    user = ADUser.new
    user.fill_from_ldap_res(entry)
    user
  end

  # alias
  def upn
    @userPrincipalName
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

    @sAMAccountName = entry["sAMAccountName"].first
    @sn = entry["sn"] ? entry["sn"].first.force_encoding("UTF-8") : " "
    @givenName = entry["givenName"] ? entry["givenName"].first.force_encoding("UTF-8") : ""
    # 33845 ma non esiste per assegnisti etc etc
    @employeeID = entry["employeeID"] ? entry["employeeID"].first.to_s : "0"
    # per i preaccreditati può non esistere
    @mail = entry["mail"] ? entry["mail"].first&.force_encoding("UTF-8") : ""
    @title = entry["title"] ? entry["title"][0] : ""    # studente / Cat. D... /
    @userPrincipalName = entry["userPrincipalName"][0]  # pietro.donatini@personale.dir.unibo.it
    @objectSid = entry["objectSid"][0]
    @idAnagraficaUnica = entry["extensionAttribute6"] ? entry["extensionAttribute6"][0] : nil

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
