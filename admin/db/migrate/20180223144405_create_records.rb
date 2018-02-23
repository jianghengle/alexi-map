class CreateRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :records do |t|
      t.integer :year
      t.integer :day
      t.integer :tile
      t.string :suffix
      t.integer :used
      t.datetime :last_used
      t.datetime :created
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
