class FixUploadedAtOnRecording < ActiveRecord::Migration[8.0]
  def change
    rename_column :recordings, :uploaded_date, :uploaded_at
  end
end
