class AddIsActiveToShows < ActiveRecord::Migration[8.0]
  def change
    add_column :shows, :is_active, :boolean
  end
end
