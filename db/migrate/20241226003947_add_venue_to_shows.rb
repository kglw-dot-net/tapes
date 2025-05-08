class AddVenueToShows < ActiveRecord::Migration[8.0]
  def change
    add_reference :shows, :venue, null: true, foreign_key: true
  end
end
