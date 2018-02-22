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
      field :is_default
      field :name
      field :map_option, :enum do
        enum do
          ['All Grids + Selection', 'Available Grids + Selection', 'Selection', 'None']
        end
      end
      field :image_option, :enum do
        enum do
          ['Grids + Selection', 'Grids', 'Selection', 'None']
        end
      end
    end
  end
end
