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

      def get_user_setting(ctx)
        begin
          user = get_user!(ctx)
          setting = Setting.get_setting!(user)
          setting.to_json
        rescue ex : InsufficientParameters
          error(ctx, "Not all required parameters were present")
        rescue e : Exception
          error(ctx, e.message.to_s)
        end
      end
    end
  end
end
