module AlexiServer
  module HttpAPI
    class Record < Crecto::Model
      schema "records" do
        field :user_id, Int32
        field :year, Int32
        field :day, Int32
        field :tile, Int32
        field :suffix, String
        field :used, Int32
        field :last_used, Time
        field :created, Time
      end

      def self.create_from_download(download)
        rd = Record.new
        rd.user_id = download.user_id
        rd.year = download.year
        rd.day = download.day
        rd.tile = download.tile
        rd.suffix = download.typ
        rd.used = download.count
        rd.last_used = download.updated_at
        rd.created = download.created_at

        changeset = Repo.insert(rd)
        raise changeset.errors.to_s unless changeset.valid?

        Download.delete_download(download)
      end
    end
  end
end
