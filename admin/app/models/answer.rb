class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question

  rails_admin do
    edit do
      field :user
      field :question
      field :content
      field :created_at
      field :updated_at
    end
  end
end
