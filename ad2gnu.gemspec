require File.expand_path("../lib/ad2gnu/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ["Pietro Donatini"]
  gem.email = ["pietro.donatini@unibo.it"]
  gem.description = "Integration with Active Directory DSA. Purpose: copy AD accounts in a local ldap server."
  gem.summary = "Integration with Active Directory DSA."

  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.name = "ad2gnu"
  gem.require_paths = ["lib"]
  gem.version = AD2Gnu::VERSION

  gem.homepage = "https://github.com/donapieppo/ad2Gnu"
  gem.licenses = ["MIT"]

  gem.add_dependency "net-ldap"
  gem.add_dependency "logger"
  gem.add_dependency "base64"
  gem.add_development_dependency "rspec"
end
