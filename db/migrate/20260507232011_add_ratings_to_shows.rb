class AddRatingsToShows < ActiveRecord::Migration[8.0]
  def change
    add_column :shows, :average_rating, :float
    add_column :shows, :count_ratings, :integer
    add_column :shows, :bayesian_rating, :float
  end
end
