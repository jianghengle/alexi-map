module AlexiServer
  module HttpAPI
    class Setting < Crecto::Model
      schema "settings" do
        field :user_id, Int32
        field :map_height, Int32
        field :map_center, String
        field :map_zoom, Int32
        field :show_grid, Bool
        field :show_selection, Bool
        field :tile_opacity, Float64
        field :selection, String
        field :tile_size, Int32
        field :is_default, Bool
        field :name, String
      end

      def to_json
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"userId\":" << @user_id << ","
          str << "\"mapHeight\":" << @map_height << ","
          str << "\"mapCenter\":" << @map_center.to_json << ","
          str << "\"mapZoom\":" << @map_zoom << ","
          str << "\"showGrid\":" << @show_grid.to_s << ","
          str << "\"showSelection\":" << @show_selection.to_s << ","
          str << "\"tileOpacity\":" << @tile_opacity << ","
          str << "\"selection\":" << @selection.to_json << ","
          str << "\"tileSize\":" << @tile_size << ","
          str << "\"isDefault\":" << @is_default << ","
          str << "\"name\":" << @name.to_json
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
        result = String.build do |str|
          first = true
          str << "["
          settings.each do |s|
            if first
              str << s.to_json
              first = false
            else
              str << ","
              str << s.to_json
            end
          end
          str << "]"
        end
        result
      end

      def self.save_setting(user, id, name, is_default, map_height, map_center, map_zoom, show_grid, show_selection, tile_opacity, selection, tile_size)
        if id == ""
          Setting.create_setting(user, name, is_default, map_height, map_center, map_zoom, show_grid, show_selection, tile_opacity, selection, tile_size)
        else
          Setting.update_setting(user, id.to_i, name, is_default, map_height, map_center, map_zoom, show_grid, show_selection, tile_opacity, selection, tile_size)
        end
      end

      def self.create_setting(user, name, is_default, map_height, map_center, map_zoom, show_grid, show_selection, tile_opacity, selection, tile_size)
        setting = Setting.new
        setting.user_id = user.id
        setting.map_height = map_height
        setting.map_center = map_center
        setting.map_zoom = map_zoom
        setting.show_grid = show_grid
        setting.show_selection = show_selection
        setting.tile_opacity = tile_opacity
        setting.selection = selection
        setting.tile_size = tile_size
        setting.is_default = is_default
        setting.name = name
        changeset = Repo.insert(setting)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_setting(user, id, name, is_default, map_height, map_center, map_zoom, show_grid, show_selection, tile_opacity, selection, tile_size)
        setting = Repo.get(Setting, id)
        raise "Cannot find setting" if setting.nil?
        setting = setting.as(Setting)
        raise "Not user's setting" if setting.user_id != user.id
        setting.map_height = map_height
        setting.map_center = map_center
        setting.map_zoom = map_zoom
        setting.show_grid = show_grid
        setting.show_selection = show_selection
        setting.tile_opacity = tile_opacity
        setting.selection = selection
        setting.tile_size = tile_size
        setting.name = name
        Setting.remove_default(user) if (setting.is_default == false && is_default)
        setting.is_default = is_default
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
