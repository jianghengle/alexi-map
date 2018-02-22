class AddFieldsToSettings < ActiveRecord::Migration[5.0]
  def change
  	add_column :settings, :map_option, :string
  	add_column :settings, :image_option, :string
  end
end
