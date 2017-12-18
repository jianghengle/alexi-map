require "pg"
require "crecto"
require "kemal"
require "json"
require "crypto/bcrypt/password"
require "secure_random"
require "oauth2"

require "./http/models/*"
require "./http/errors/*"
require "./http/controllers/*"
require "./http/middleware/*"

module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = ENV["PG_URL"]
  end
end

Query = Crecto::Repo::Query

module AlexiServer
  class Server
    def initialize
      # Middlewares
      add_handler HttpAPI::ApiHandler.new

      get "/" do |env|
        env.redirect "/index.html"
      end

      post "/get_auth_token" do |env|
        HttpAPI::UserController.get_auth_token(env)
      end

      port = 3000
      port = ENV["ALEXI_PORT"].to_i if ENV.has_key?("ALEXI_PORT")
      Kemal.run port
    end
  end
end

AlexiServer::Server.new
