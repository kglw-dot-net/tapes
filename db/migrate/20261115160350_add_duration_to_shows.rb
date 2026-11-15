class AddDurationToShows < ActiveRecord::Migration[8.1]
  def change
    add_column :shows, :duration, :float
  end
end
