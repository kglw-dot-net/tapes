class AddUpvotesToSetSongs < ActiveRecord::Migration[8.0]
  def change
    add_column :set_songs, :upvotes, :integer
  end
end
