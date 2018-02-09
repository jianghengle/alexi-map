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
          setting_data = Setting.new
          setting_data.name = get_param!(ctx, "name")
          setting_data.is_default = get_param!(ctx, "isDefault") == "true"
          setting_data.map_height = get_param!(ctx, "mapHeight").to_i
          setting_data.map_center = get_param!(ctx, "mapCenter")
          setting_data.map_zoom = get_param!(ctx, "mapZoom").to_i
          setting_data.show_grid = get_param!(ctx, "showGrid") == "true"
          setting_data.show_selection = get_param!(ctx, "showSelection") == "true"
          setting_data.tile_opacity = get_param!(ctx, "tileOpacity").to_f
          setting_data.selection = get_param!(ctx, "selection")
          setting_data.tile_size = get_param!(ctx, "tileSize").to_i
          Setting.save_setting(user, id, setting_data)
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
