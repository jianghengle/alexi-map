class Record < ApplicationRecord
  belongs_to :user

  rails_admin do
    edit do
      field :user
      field :year
      field :day
      field :tile
      field :suffix
      field :used
      field :last_used
      field :created
    end
  end
end
