class AddPosterUrlToShows < ActiveRecord::Migration[8.0]
  def change
    add_column :shows, :poster_url, :string
  end
end
