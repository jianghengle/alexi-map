class Question < ApplicationRecord
  belongs_to :user

  rails_admin do
    edit do
      field :user
      field :subject
      field :content
      field :created_at
      field :updated_at
    end
  end
end
