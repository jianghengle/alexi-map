require "pg"
require "crecto"
require "json"

require "./http/models/*"

module Repo
  extend Crecto::Repo

  config do |conf|
    conf.adapter = Crecto::Adapters::Postgres
    conf.uri = ENV["PG_URL"]
  end
end

Query = Crecto::Repo::Query

module AlexiServer
  class Maintainer
    def initialize
      begin
        downloads = HttpAPI::Download.get_all_downloads
        return if downloads.empty?

        now = Time.now
        download_ids = [] of Int32 | Int64 | Nil
        downloads.each do |download|
          download = download.as(HttpAPI::Download)
          span = now - download.created_at.as(Time)
          next if span.total_minutes < 180

          count = download.count
          if count.nil?
            download_ids << download.id
          elsif (count.as(Int32) == 0)
            download_ids << download.id
          else
            HttpAPI::Record.create_from_download(download)
          end
        end

        return if download_ids.empty?
        query = Query.where(:id, download_ids)
        Repo.delete_all(HttpAPI::Download, query)
        puts now
        puts (Time.now - now)
        puts "Done database maintainence!"
      rescue e : Exception
        puts "Failed to maintain the database!"
        puts e.message.to_s
      end
    end
  end
end

AlexiServer::Maintainer.new
