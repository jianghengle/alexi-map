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
          str << "\"tileSize\":" << @tile_size
          str << "}"
        end
        result
      end

      def self.get_setting(user)
        return nil if user.nil?
        Repo.get_by(Setting, user_id: user.id)
      end

      def self.get_setting!(user)
        setting = Repo.get_by(Setting, user_id: user.id)
        raise "cannot find setting" if setting.nil?
        setting.as(Setting)
      end
    end
  end
end
