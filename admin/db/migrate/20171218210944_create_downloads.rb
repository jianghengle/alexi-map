class CreateDownloads < ActiveRecord::Migration[5.0]
  def change
    create_table :downloads do |t|
      t.string :key
      t.integer :year
      t.integer :day
      t.integer :tile
      t.string :type
      t.integer :count
      t.references :user, foreign_key: true

      t.timestamps
    end

    add_index :downloads, :key, unique: true
  end
end
