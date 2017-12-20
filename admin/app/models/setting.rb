class Setting < ApplicationRecord
  belongs_to :user

  rails_admin do
    edit do
      field :user
      field :map_height
      field :map_center
      field :map_zoom
      field :show_grid
      field :show_selection
      field :tile_opacity
      field :selection
      field :tile_size
    end
  end
end
