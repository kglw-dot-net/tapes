class AddIsActiveToRecordings < ActiveRecord::Migration[8.0]
  def change
    add_column :recordings, :is_active, :boolean
  end
end
