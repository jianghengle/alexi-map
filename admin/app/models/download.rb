class Download < ApplicationRecord
  belongs_to :user

  rails_admin do
    edit do
      field :user
      field :key
      field :year
      field :day
      field :tile
      field :typ, :enum do
        enum do
          ['tif', 'png']
        end
      end
      field :count
      field :created_at
      field :updated_at
    end
  end
end
