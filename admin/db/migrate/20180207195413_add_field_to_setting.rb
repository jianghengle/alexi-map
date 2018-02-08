class AddFieldToSetting < ActiveRecord::Migration[5.0]
  def change
  	add_column :settings, :is_default, :boolean
  	add_column :settings, :name, :string
  end
end
