class FixSongSetReferenceToSetlists < ActiveRecord::Migration[8.0]
  def change
    remove_reference :set_songs, :set, foreign_key: true
    add_reference :set_songs, :setlist, null: false, foreign_key: true
  end
end
