class CreateSetSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :set_songs do |t|
      t.integer :songfishID
      t.references :set, null: false, foreign_key: true
      t.references :song, null: false, foreign_key: true
      t.integer :position
      t.float :duration
      t.text :footnote
      t.boolean :is_jamchart
      t.text :jamchart_notes
      t.boolean :is_reprise
      t.boolean :is_verified
      t.boolean :is_recommended
      t.boolean :is_jam
      t.references :transition, null: false, foreign_key: true

      t.timestamps
    end
  end
end
