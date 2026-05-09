class AddTitleOverrideToRecordingFiles < ActiveRecord::Migration[8.0]
  def change
    add_column :recording_files, :title_override, :string
  end
end
