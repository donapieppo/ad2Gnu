#!/usr/bin/env ruby

require "thin"
require "ad2gnu"

class UserCreation
  def add_user(uid, domain)
    domain ||= :studenti
    puts "Provo a creare '#{uid}' in '#{domain}'"
    linuxdsa = AD2Gnu::Base.new(domain.to_sym).AD_login.local_login
    user = linuxdsa.ad.get_user(uid) or return "Non esiste #{uid} in AD"
    p user
    if linuxdsa.local.exists?(user)
      "Utente già presente in locale"
    else
      linuxdsa.local.add_user(user)
      "OK"
    end
  end

  def correct_uid(uid)
    uid.downcase =~ /^[a-z][a-z0-9]+\.[a-z][a-z0-9]+$/
  end

  def call(env)
    req = Rack::Request.new(env)
    puts "params=#{req.params.inspect}"
    uid = req.params["u"]
    domain = req.params["d"]
    if correct_uid(uid)
      res = add_user(uid, domain)
      [200, {"Content-Type" => "text/plain"}, [res]]
    else
      [200, {"Content-Type" => "text/plain"}, ["Devi darmi u=nome.cognome"]]
    end
  end
end

# Thin::Server.start('0.0.0.0', 3000, app)
# All requests will be processed through app that must be a valid Rack adapter. 
# A valid Rack adapter (application) must respond to call(env#Hash) 
# and return an array of [status, headers, body].
Thin::Server.start("0.0.0.0", 3000) do
  use Rack::CommonLogger
  use Rack::Static, urls: ["/index.html", "/css"],
                    root: File.expand_path(File.dirname(__FILE__)),
                    index: "/index.html"
  map "/create" do
    run UserCreation.new
  end
end

# You could also start the server like this:
#
# app = Rack::URLMap.new('/test' => SimpleAdapter.new,
# '/files' => Rack::File.new('.'))
# Thin::Server.start('0.0.0.0', 3000, app)
