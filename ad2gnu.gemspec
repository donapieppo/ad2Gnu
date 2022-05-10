# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ad2gnu/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Pietro Donatini"]
  gem.email         = ["pietro.donatini@unibo.it"]
  gem.description   = %q{Integration with Active Directory DSA. Purpose: copy accounts in local ldap, search AD users.}
  gem.summary       = %q{Integration with Active Directory DSA}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ad2gnu"
  gem.require_paths = ["lib"]
  gem.version       = AD2Gnu::VERSION

  gem.homepage      = 'https://github.com/donapieppo/ad2Gnu'
  gem.licenses     = ['MIT']

  gem.add_dependency "ruby-ldap"
end
