module AD2Gnu
  class Conf
    attr_reader :debug, :ldap, :ad, :account, :groups

    def initialize(file = "/etc/ad2gnu.yml")
      @yaml = YAML.safe_load(File.read(file), permitted_classes: [], permitted_symbols: [], aliases: false)
      @debug = @yaml["debug"] || false
      @ldap = @yaml["ldap"]
      @ad = @yaml["ad"]
      @account = @yaml["account"]
      @groups = @yaml["groups"] || []
    end
  end
end
