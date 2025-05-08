class AddTrackNumberToSongs < ActiveRecord::Migration[8.0]
  def change
    add_column :songs, :track_number, :integer
  end
end
