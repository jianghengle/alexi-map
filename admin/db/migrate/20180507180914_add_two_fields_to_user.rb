class AddTwoFieldsToUser < ActiveRecord::Migration[5.0]
  def change
  	add_column :users, :status, :string
    add_column :users, :verification_key, :string

    add_index :users, :verification_key
  end
end
