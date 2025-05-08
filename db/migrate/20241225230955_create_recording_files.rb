class CreateRecordingFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :recording_files do |t|
      t.string :source
      t.string :format
      t.float :length
      t.string :original
      t.string :title
      t.integer :track_no
      t.boolean :is_private
      t.string :creator
      t.string :album

      t.timestamps
    end
  end
end
