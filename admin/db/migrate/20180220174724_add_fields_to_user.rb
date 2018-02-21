class AddFieldsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :country, :string
    add_column :users, :state, :string
    add_column :users, :city, :string
    add_column :users, :affiliation, :string
    add_column :users, :employer, :string
    add_column :users, :title, :string
    add_column :users, :purpose, :string
    add_column :users, :hear_from, :string
  end
end
