class AddRecordingToRecordingFiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :recording_files, :recording, type: :string, null: false, foreign_key: true
  end
end
