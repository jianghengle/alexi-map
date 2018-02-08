require "./controller_base"

module AlexiServer
  module HttpAPI
    module UserController
      include AlexiServer::HttpAPI::ControllerBase
      extend self

      def get_auth_token(ctx)
        begin
          email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")

          user = User.get_user_by_password!(email, password)
          token = user.auth_token.to_s
          email = user.email.to_s
          {token: token, email: email}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_user_profile(ctx)
        begin
          user = get_user!(ctx)
          user.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_user_settings(ctx)
        begin
          user = get_user!(ctx)
          Setting.get_settings_json(user)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def save_user_setting(ctx)
        begin
          user = get_user!(ctx)
          id = get_param!(ctx, "id")
          name = get_param!(ctx, "name")
          is_default = get_param!(ctx, "isDefault") == "true"
          map_height = get_param!(ctx, "mapHeight").to_i
          map_center = get_param!(ctx, "mapCenter")
          map_zoom = get_param!(ctx, "mapZoom").to_i
          show_grid = get_param!(ctx, "showGrid") == "true"
          show_selection = get_param!(ctx, "showSelection") == "true"
          tile_opacity = get_param!(ctx, "tileOpacity").to_f
          selection = get_param!(ctx, "selection")
          tile_size = get_param!(ctx, "tileSize").to_i
          Setting.save_setting(user, id, name, is_default, map_height, map_center, map_zoom, show_grid, show_selection, tile_opacity, selection, tile_size)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def delete_user_setting(ctx)
        begin
          user = get_user!(ctx)
          id = get_param!(ctx, "id")
          Setting.delete_setting(user, id)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
