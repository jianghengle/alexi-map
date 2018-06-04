require "./controller_base"

module AlexiServer
  module HttpAPI
    module UserController
      include AlexiServer::HttpAPI::ControllerBase
      extend self

      def register(ctx)
        begin
          new_user = User.new
          new_user.email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")
          encrypted_password = Crypto::Bcrypt::Password.create(password)
          raise "failed to encrypted password" if encrypted_password.nil?
          new_user.encrypted_password = encrypted_password.to_s
          new_user.status = "Inactive"
          new_user.first_name = get_param!(ctx, "firstName")
          new_user.last_name = get_param!(ctx, "lastName")
          new_user.country = get_param!(ctx, "country")
          new_user.state = get_param!(ctx, "state")
          new_user.city = get_param!(ctx, "city")
          new_user.affiliation = get_param!(ctx, "affiliation")
          new_user.employer = get_param!(ctx, "employer")
          new_user.title = get_param!(ctx, "title")
          new_user.purpose = get_param!(ctx, "purpose")
          new_user.hear_from = get_param!(ctx, "hearFrom")

          subscribe_wfi = get_param!(ctx, "subscribeWFI")
          subscribe_ndmc = get_param!(ctx, "subscribeNDMC")

          user = User.create_user(new_user, subscribe_wfi, subscribe_ndmc)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_auth_token(ctx)
        begin
          email = get_param!(ctx, "email")
          password = get_param!(ctx, "password")

          user = User.get_user_by_password!(email, password)
          raise "User is not active!" if user.status.to_s != "Active"
          token = user.auth_token.to_s
          email = user.email.to_s
          first_name = user.first_name.to_s
          last_name = user.last_name.to_s
          role = user.role.to_s
          id = user.id.to_s
          {token: token, email: email, firstName: first_name, lastName: last_name, role: role, id: id}.to_json
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

      def update_user_profile(ctx)
        begin
          user = get_user!(ctx)
          user.first_name = get_param!(ctx, "firstName")
          user.last_name = get_param!(ctx, "lastName")
          user.country = get_param!(ctx, "country")
          user.state = get_param!(ctx, "state")
          user.city = get_param!(ctx, "city")
          user.affiliation = get_param!(ctx, "affiliation")
          user.employer = get_param!(ctx, "employer")
          user.title = get_param!(ctx, "title")
          user.purpose = get_param!(ctx, "purpose")
          user.hear_from = get_param!(ctx, "hearFrom")
          User.update_user(user)
          user.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def update_user_password(ctx)
        begin
          user = get_user!(ctx)
          old_password = get_param!(ctx, "oldPassword")
          new_password = get_param!(ctx, "newPassword")
          User.update_user_password(user, old_password, new_password)
          {ok: true}.to_json
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
          setting_data.tile_opacity = get_param!(ctx, "tileOpacity").to_f
          setting_data.selection = get_param!(ctx, "selection")
          setting_data.tile_size = get_param!(ctx, "tileSize").to_i
          setting_data.map_option = get_param!(ctx, "mapOption")
          setting_data.image_option = get_param!(ctx, "imageOption")
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

      def get_all_users(ctx)
        begin
          user = get_user!(ctx)
          raise "Permission denied!" unless user.role.to_s == "Admin"
          User.get_all_users_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def get_user(ctx)
        begin
          user = get_user!(ctx)
          raise "Permission denied!" unless user.role.to_s == "Admin"
          id = get_param!(ctx, "id")
          User.get_user_json(id)
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def send_verification(ctx)
        begin
          user = get_user!(ctx)
          raise "Permission denied!" unless user.role.to_s == "Admin"
          id = get_param!(ctx, "id")
          User.send_verification(id)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def verify_user(ctx)
        begin
          key = get_param!(ctx, "key")
          raise "No such key" if key == ""
          User.verify_user(key)
          ctx.response.content_type = "text/html"
          server_url = "http://localhost:8080/"
          server_url = ENV["SERVER_URL"] + "/index.html" if ENV.has_key?("SERVER_URL")
          "<html><body><p>Your account has been activated. You can go ahead <a href=\"#{server_url}\#/login\">login</a> now.</p></body></html>"
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def deactivate_user(ctx)
        begin
          user = get_user!(ctx)
          raise "Permission denied!" unless user.role.to_s == "Admin"
          id = get_param!(ctx, "id")
          User.deactivate_user(id)
          {ok: true}.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end

      def contact_us(ctx)
        begin
          content = get_param!(ctx, "content")
          a = get_param!(ctx, "a").to_i
          b = get_param!(ctx, "b").to_i
          c = get_param!(ctx, "c").to_i

          raise "failed to verify human" unless a + b == c
          t = a - b
          now = Time.now
          h = (now.epoch / 3600) % 4
          puts t
          puts h
          raise "failed to verify human!" unless (t == h || (t + 1) % 4 == h)

          User.contact_us(content)
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
