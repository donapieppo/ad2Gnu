require 'yaml'
require 'ldap'

require "ad2gnu/version"
require "ad2gnu/conf"
require "ad2gnu/base"
require "ad2gnu/ldap"
require "ad2gnu/ad"
require "ad2gnu/aduser"
require "ad2gnu/local"
require "ad2gnu/localuser"
require "ad2gnu/localgroup"
require "ad2gnu/sambasid"

module AD2Gnu
  class NoIdAnagraficaUnicaError < StandardError #:nodoc:
  end
    
  class NotFoundError < StandardError #:nodoc:
  end

  class AlreadyExistsError < StandardError #:nodo:
  end
end
