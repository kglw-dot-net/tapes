class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.integer :songfishID
      t.string :name
      t.string :slug
      t.boolean :is_original

      t.timestamps
    end
  end
end
