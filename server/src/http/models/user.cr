module AlexiServer
  module HttpAPI
    class User < Crecto::Model
      schema "users" do
        field :email, String
        field :encrypted_password, String
        field :first_name, String
        field :last_name, String
        field :auth_token, String
        field :role, String
        validate_required [:email]
      end

      def self.get_user_by_password!(email, password)
        user = Repo.get_by(User, email: email)
        raise "Cannot find user" if user.nil?
        raise "Cannot verify password" unless Crypto::Bcrypt::Password.new(user.encrypted_password.not_nil!) == password
        user.as(User)
      end

      def self.get_user_by_token!(token : String)
        user = Repo.get_by(User, auth_token: token)
        raise "Cannot find user" if user.nil?
        user.as(User)
      end

      def self.get_user_by_token(token : String)
        Repo.get_by(User, auth_token: token)
      end
    end
  end
end
