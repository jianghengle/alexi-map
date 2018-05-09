class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  before_create :set_auth_token

  def set_auth_token
    self[:auth_token] = SecureRandom.base64(32)
  end

  rails_admin do
    edit do
      field :email
      field :password
      field :password_confirmation
      field :auth_token
      field :status, :enum do
        enum do
          ['Active', 'Inactive', 'Verifying']
        end
      end
      field :verification_key

      field :first_name
      field :last_name
      field :role, :enum do
        enum do
          ['Admin', 'Normal']
        end
      end
      field :country
      field :state
      field :city
      field :affiliation
      field :employer
      field :title
      field :purpose
      field :hear_from
    end
  end

end
