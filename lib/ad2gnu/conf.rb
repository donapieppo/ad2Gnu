module AD2Gnu
  class Conf
    attr_reader :debug, :ldap, :ad, :account, :groups

    def initialize(file = "/etc/ad2gnu.yml")
      @yaml = YAML.load(File.open(file))
      @debug = @yaml["debug"] || false
      @ldap = @yaml["ldap"]
      @ad = @yaml["ad"]
      @account = @yaml["account"]
      @groups = @yaml["groups"] || []
    end
  end
end
