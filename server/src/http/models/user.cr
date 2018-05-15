module AlexiServer
  module HttpAPI
    class User < Crecto::Model
      schema "users" do
        field :email, String
        field :encrypted_password, String
        field :status, String
        field :verification_key, String
        field :first_name, String
        field :last_name, String
        field :auth_token, String
        field :role, String
        field :country, String
        field :state, String
        field :city, String
        field :affiliation, String
        field :employer, String
        field :title, String
        field :purpose, String
        field :hear_from, String
        validate_required [:email]
      end

      def to_json(subscribe_wfi = false, subscribe_ndmc = false)
        result = String.build do |str|
          str << "{"
          str << "\"id\":" << @id << ","
          str << "\"email\":" << @email.to_json << ","
          str << "\"firstName\":" << @first_name.to_json << ","
          str << "\"lastName\":" << @last_name.to_json << ","
          str << "\"role\":" << @role.to_json << ","
          str << "\"status\":" << @status.to_json << ","
          str << "\"verificationKey\":" << @verification_key.to_json << ","
          str << "\"country\":" << @country.to_json << ","
          str << "\"state\":" << @state.to_json << ","
          str << "\"city\":" << @city.to_json << ","
          str << "\"affiliation\":" << @affiliation.to_json << ","
          str << "\"employer\":" << @employer.to_json << ","
          str << "\"title\":" << @title.to_json << ","
          str << "\"purpose\":" << @purpose.to_json << ","
          str << "\"hearFrom\":" << @hear_from.to_json << ","
          str << "\"subscribe_wfi\":" << subscribe_wfi.to_s << ","
          str << "\"subscribe_ndmc\":" << subscribe_ndmc.to_s << ","
          str << "\"createdTime\":" << @created_at.as(Time).epoch << ","
          str << "\"updatedTime\":" << @updated_at.as(Time).epoch
          str << "}"
        end
        result
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

      def self.create_user(new_user, subscribe_wfi, subscribe_ndmc)
        user = Repo.get_by(User, email: new_user.email)
        raise "User existed!" unless user.nil?

        new_user.auth_token = Random::Secure.base64(32).to_s
        new_user.role = "Normal"
        changeset = Repo.insert(new_user)
        raise changeset.errors.to_s unless changeset.valid?

        user = Repo.get_by(User, email: new_user.email)
        raise "Cannot find new user" if user.nil?
        Setting.create_setting(user)
        User.send_admins_email(user, subscribe_wfi, subscribe_ndmc)
        user
      end

      def self.send_admins_email(new_user, subscribe_wfi, subscribe_ndmc)
        query = Query.where(role: "Admin")
        admins = Repo.all(User, query)
        return new_user if admins.nil?
        admins = admins.as(Array)
        return if admins.empty?
        emails = admins.map { |a| a.email.to_s }
        admins_json = emails.to_json
        new_user_json = new_user.to_json(subscribe_wfi, subscribe_ndmc)

        return unless ENV.has_key?("SEND_EMAIL_DIR")
        send_email_dir = ENV["SEND_EMAIL_DIR"]
        return unless File.directory?(send_email_dir)
        send_email_script = send_email_dir + "/sendemail.py"
        return unless File.file?(send_email_script)
        input_text = admins_json + "\n\"New GloDET User Registered\"\n" + new_user_json.to_json
        File.write(send_email_dir + "/emailinput.txt", input_text)
        command = "python \"#{send_email_script}\""
        puts command
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        puts io.to_s
      end

      def self.update_user(user)
        changeset = Repo.update(user)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.update_user_password(user, old_password, new_password)
        raise "Cannot verify old password" unless Crypto::Bcrypt::Password.new(user.encrypted_password.not_nil!) == old_password
        encrypted_password = Crypto::Bcrypt::Password.create(new_password)
        raise "failed to encrypted password" if encrypted_password.nil?
        user.encrypted_password = encrypted_password.to_s
        changeset = Repo.update(user)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.get_all_users_json
        users = Repo.all(User)
        return "[]" if users.nil?
        users = users.as(Array)
        arr = users.map do |u|
          String.build do |str|
            str << "{"
            str << "\"id\":" << u.id << ","
            str << "\"email\":" << u.email.to_json << ","
            str << "\"firstName\":" << u.first_name.to_json << ","
            str << "\"lastName\":" << u.last_name.to_json << ","
            str << "\"registeredAt\":" << u.created_at.as(Time).epoch << ","
            str << "\"status\":" << u.status.to_json
            str << "}"
          end
        end
        "[#{arr.join(",")}]"
      end

      def self.get_user_json(id)
        user = Repo.get(User, id)
        return "null" if user.nil?
        user = user.as(User)
        user.to_json
      end

      def self.send_verification(id)
        user = Repo.get(User, id)
        raise "Cannot find the user" if user.nil?
        user = user.as(User)
        raise "User is already active" if user.status.to_s == "Active"
        user.status = "Verifying"
        if (user.verification_key.nil? || user.verification_key.to_s == "")
          user.verification_key = Random::Secure.hex.to_s
        end

        changeset = Repo.update(user)
        raise changeset.errors.to_s unless changeset.valid?
        User.send_verification_email(user)
      end

      def self.send_verification_email(user)
        return unless ENV.has_key?("SEND_EMAIL_DIR")
        send_email_dir = ENV["SEND_EMAIL_DIR"]
        return unless File.directory?(send_email_dir)
        send_email_script = send_email_dir + "/sendemail.py"
        return unless File.file?(send_email_script)

        address = "[\"#{user.email}\"]"
        subject = "Activate Your GloDET Account"

        text = "Hi there,\n\nThanks for registering GloDET. Please use the following link:\n"
        server_url = "http://localhost:3000"
        server_url = ENV["SERVER_URL"] if ENV.has_key?("SERVER_URL")
        activation_url = server_url + "/verify_user/" + user.verification_key.to_s
        text = text + activation_url + "\n"
        text = text + "to activate your account.\n\nBest,\nGloDET Support"

        html = "<html><body><p>Hi there,</p><p>Thanks for registering GloDET. Please use the following link:</p>"
        html = html + "<p><a href=\"#{activation_url}\">#{activation_url}</a></p>"
        html = html + "<p>to activate your account.</p><p>Best,</p><p>GloDET Support</p></body></html>"

        input_text = address + "\n" + subject.to_json + "\n" + text.to_json + "\n" + html.to_json
        File.write(send_email_dir + "/emailinput.txt", input_text)
        command = "python \"#{send_email_script}\""
        puts command
        io = IO::Memory.new
        Process.run(command, shell: true, output: io)
        puts io.to_s
      end

      def self.verify_user(key)
        user = Repo.get_by(User, verification_key: key)
        raise "Cannot find user" if user.nil?
        user = user.as(User)
        user.status = "Active"
        changeset = Repo.update(user)
        raise changeset.errors.to_s unless changeset.valid?
      end

      def self.deactivate_user(id)
        user = Repo.get(User, id)
        raise "Cannot find the user" if user.nil?
        user = user.as(User)
        raise "User is admin" if user.role.to_s == "Admin"
        raise "User is not active" unless user.status.to_s == "Active"
        user.status = "Inactive"
        user.verification_key = ""
        changeset = Repo.update(user)
        raise changeset.errors.to_s unless changeset.valid?
      end
    end
  end
end
