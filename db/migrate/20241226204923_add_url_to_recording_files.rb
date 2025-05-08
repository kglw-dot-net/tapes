class AddUrlToRecordingFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :recording_files, :url, :string
  end
end
