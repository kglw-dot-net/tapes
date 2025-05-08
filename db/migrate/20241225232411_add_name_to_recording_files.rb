class AddNameToRecordingFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :recording_files, :name, :string
  end
end
