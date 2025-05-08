class RemoveYearFromAlbums < ActiveRecord::Migration[8.0]
  def change
    remove_column :albums, :year, :string
  end
end
