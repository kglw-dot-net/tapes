class AddColorToShows < ActiveRecord::Migration[8.0]
  def change
    add_column :shows, :color, :string
  end
end
