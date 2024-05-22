require "yaml"
require "net/ldap"
require "logger"

require "ad2gnu/version"
require "ad2gnu/conf"
require "ad2gnu/base"
require "ad2gnu/ldap"
require "ad2gnu/ad"
require "ad2gnu/aduser"
require "ad2gnu/local"
require "ad2gnu/local_user"
require "ad2gnu/local_group"
require "ad2gnu/sambasid"

module AD2Gnu
  class ResultError < StandardError # :nodoc:
  end

  class NoIdAnagraficaUnicaError < StandardError # :nodoc:
  end

  class NotFoundError < StandardError # :nodoc:
  end

  class AlreadyExistsError < StandardError # :nodoc:
  end
end
