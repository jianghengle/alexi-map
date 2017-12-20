require "./controller_base"

module AlexiServer
  module HttpAPI
    module TileController
      include AlexiServer::HttpAPI::ControllerBase
      extend self

      def get_days_in_year(ctx)
        begin
          year = get_param!(ctx, "year")
          days = Tile.get_days_in_year(year.to_i)
          days.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_tiles_in_day(ctx)
        begin
          year = get_param!(ctx, "year")
          day = get_param!(ctx, "day")
          tiles = Tile.get_tiles_in_day(year.to_i, day.to_i)
          tiles.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_latest_tiles(ctx)
        begin
          years = Tile.get_years_range
          raise "root is empty" if years.empty?
          days = Tile.get_days_in_year(years[1])
          tiles = Tile.get_tiles_in_day(years[1], days[-1])
          user = get_user(ctx)
          setting = Setting.get_setting(user)
          setting_json = setting.nil? ? "null" : setting.to_json
          "[#{setting_json}, #{years.to_json},#{days.to_json},#{tiles.to_json}]"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
