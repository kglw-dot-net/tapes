class AddTourToShows < ActiveRecord::Migration[8.0]
  def change
    add_reference :shows, :tour, null: true, foreign_key: true
  end
end
