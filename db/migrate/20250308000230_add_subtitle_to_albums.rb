class AddSubtitleToAlbums < ActiveRecord::Migration[8.0]
  def change
    add_column :albums, :subtitle, :string
  end
end
