class AddRecordingTypeToRecordings < ActiveRecord::Migration[8.0]
  def change
    add_reference :recordings, :recording_type, null: true, foreign_key: true
  end
end
