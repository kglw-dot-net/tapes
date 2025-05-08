class AddPreferredFormatToRecordings < ActiveRecord::Migration[8.0]
  def change
    add_column :recordings, :preferred_format, :string
  end
end
