class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.integer :map_height
      t.string :map_center
      t.integer :map_zoom
      t.boolean :show_grid
      t.boolean :show_selection
      t.float :tile_opacity
      t.string :selection
      t.integer :tile_size
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
