class CreateAlbums < ActiveRecord::Migration[8.0]
  def change
    create_table :albums do |t|
      t.string :title
      t.integer :year
      t.string :cover_art_url

      t.timestamps
    end
  end
end
