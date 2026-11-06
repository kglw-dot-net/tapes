class AddIsIncompleteToRecordings < ActiveRecord::Migration[8.1]
  def change
    add_column :recordings, :is_incomplete, :boolean, default: false
  end
end
