class AddReleaseDateToAlbums < ActiveRecord::Migration[8.0]
  def change
    add_column :albums, :release_date, :date
  end
end
