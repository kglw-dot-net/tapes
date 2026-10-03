class AddArtistsToShows < ActiveRecord::Migration[8.1]
  def change
    add_reference :shows, :artist, null: true, foreign_key: true
  end
end
