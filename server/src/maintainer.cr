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
        if downloads.empty?
          puts "No downloads at all"
          puts "Done database maintainence!"
          return
        end

        now = Time.now
        download_ids = [] of Int8 | Int16 | Int32 | Int64 | String | Nil
        moved = 0

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
            moved = moved + 1
          end
        end

        puts "Moved #{moved} records"

        if download_ids.empty?
          puts "No download needs to be deleted"
        else
          query = Query.where(:id, download_ids)
          Repo.delete_all(HttpAPI::Download, query)
          puts "Deleted #{download_ids.size} downloads"
        end
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
