module AlexiServer
  module HttpAPI
    class Download < Crecto::Model
      schema "downloads" do
        field :user_id, Int32
        field :key, String
        field :year, Int32
        field :day, Int32
        field :tile, Int32
        field :typ, String
        field :count, Int32
      end

      raise "No root setup" unless ENV.has_key?("ALEXI_ROOT")
      @@root = ENV["ALEXI_ROOT"]

      def to_url
        result = String.build do |str|
          str << "/download_file/"
          str << @key
        end
        result
      end

      def to_file_path
        yyyy = @year.to_s
        ddd = Download.fill_zero(@day.as(Int32), 3)
        ttt = Download.fill_zero(@tile.as(Int32).to_i, 3)
        typ = @typ.to_s
        filename = "FINAL_EDAY_#{yyyy}#{ddd}_T#{ttt}.#{typ}"
        path = File.join(@@root, yyyy, ddd, filename)
        raise "cannot find file" unless File.file? path
        path
      end

      def self.create_download(user, year, day, tile, typ)
        yyyy = year.to_s
        ddd = Download.fill_zero(day, 3)
        ttt = Download.fill_zero(tile, 3)
        filename = "FINAL_EDAY_#{yyyy}#{ddd}_T#{ttt}.#{typ}"
        path = File.join(@@root, yyyy, ddd, filename)
        raise "cannot find file" unless File.file? path
        download = Download.new
        download.user_id = user.id unless user.nil?
        download.key = Random::Secure.urlsafe_base64(32).to_s
        download.year = year
        download.day = day
        download.tile = tile
        download.typ = typ
        download.count = 0
        changeset = Repo.insert(download)
        raise changeset.errors.to_s unless changeset.valid?
        download
      end

      def self.get_download(key)
        download = Repo.get_by(Download, key: key)
        raise "cannot find download" if download.nil?
        download = download.as(Download)
        now = Time.now
        span = now - download.created_at.as(Time)
        raise "download expired" if (download.typ.to_s == "tif" && span.total_minutes > 180)
        download.count = download.count.as(Int32) + 1
        changeset = Repo.update(download)
        raise changeset.errors.to_s unless changeset.valid?
        download
      end

      def self.fill_zero(num, digits)
        n = num.to_s
        raise "wrong number" if n.size > digits
        while n.size < digits
          n = "0#{n}"
        end
        n
      end

      def self.get_all_downloads
        downloads = Repo.all(Download)
        return [] of Download if downloads.nil?
        downloads.as(Array)
      end

      def self.delete_download(download)
        changeset = Repo.delete(download)
        raise changeset.errors.to_s unless changeset.valid?
      end
    end
  end
end
