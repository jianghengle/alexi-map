module AlexiServer
  module HttpAPI
    class Setting < Crecto::Model
      schema "settings" do
        field :user_id, Int32
        field :map_height, Int32
        field :map_center, String
        field :map_zoom, Int32
        field :tile_opacity, Float64
        field :selection, String
        field :tile_size, Int32
        field :is_default, Bool
        field :name, String
        field :map_option, String
        field :image_option, String
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"mapHeight\":" << @map_height << ","
          str << "\"mapCenter\":" << @map_center.to_json << ","
          str << "\"mapZoom\":" << @map_zoom << ","
          str << "\"tileOpacity\":" << @tile_opacity << ","
          str << "\"selection\":" << @selection.to_json << ","
          str << "\"tileSize\":" << @tile_size << ","
          str << "\"isDefault\":" << @is_default << ","
          str << "\"name\":" << @name.to_json << ","
          str << "\"mapOption\":" << @map_option.to_json << ","
          str << "\"imageOption\":" << @image_option.to_json
          str << "}"
        end
        result
      end

      def self.get_settings_json(user)
        return "[]" if user.nil?
        Repo.get_by(Setting, user_id: user.id)
        query = Query.where(user_id: user.id)
        settings = Repo.all(Setting, query)
        return "[]" if settings.nil?
        settings = settings.as(Array)
        index = 0
        settings.each_with_index do |s, i|
          index = i if s.is_default
        end
        settings.swap(index, 0) unless index == 0
        json_arr = settings.map { |s| s.to_json }
        json_str = json_arr.join(",")
        "[#{json_str}]"
      end

      def self.save_setting(user, id, setting_data)
        if id == ""
          Setting.create_setting(user, setting_data)
        else
          Setting.update_setting(user, id.to_i, setting_data)
        end
      end

      def self.create_setting(user, setting_data = nil)
        if setting_data.nil?
          setting = Setting.new
          setting.name = "Default"
          setting.is_default = true
          setting.map_height = 600
          setting.map_center = "22.5, 22.5"
          setting.map_zoom = 3
          setting.tile_opacity = 0.6
          setting.selection = "25, 20, 25, 20"
          setting.tile_size = 200
          setting.map_option = "All Grids + Selection"
          setting.image_option = "Grids + Selection"
        else
          setting = setting_data.as(Setting)
        end
        setting.user_id = user.id
        changeset = Repo.insert(setting)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_setting(user, id, setting_data)
        setting = Repo.get(Setting, id)
        raise "Cannot find setting" if setting.nil?
        setting = setting.as(Setting)
        raise "Not user's setting" if setting.user_id != user.id
        setting.map_height = setting_data.map_height
        setting.map_center = setting_data.map_center
        setting.map_zoom = setting_data.map_zoom
        setting.tile_opacity = setting_data.tile_opacity
        setting.selection = setting_data.selection
        setting.tile_size = setting_data.tile_size
        setting.name = setting_data.name
        setting.map_option = setting_data.map_option
        setting.image_option = setting_data.image_option
        Setting.remove_default(user) if (!setting.is_default && setting_data.is_default)
        setting.is_default = setting_data.is_default
        changeset = Repo.update(setting)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.remove_default(user)
        Repo.get_by(Setting, user_id: user.id)
        query = Query.where(user_id: user.id)
        settings = Repo.all(Setting, query)
        return if settings.nil?
        settings = settings.as(Array)
        settings.each do |s|
          s.is_default = false
          changeset = Repo.update(s)
          raise changeset.errors.to_s unless changeset.valid?
        end
      end

      def self.delete_setting(user, id)
        setting = Repo.get(Setting, id)
        raise "Cannot find setting" if setting.nil?
        setting = setting.as(Setting)
        raise "Not user's setting" if setting.user_id != user.id
        changeset = Repo.delete(setting)
        raise changeset.errors.to_s unless changeset.valid?
      end
    end
  end
end
