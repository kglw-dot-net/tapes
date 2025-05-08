class AddDatesAndIsLmaToRecordings < ActiveRecord::Migration[8.0]
  def change
    add_column :recordings, :recorded_at, :date
    add_column :recordings, :uploaded_date, :datetime
    add_column :recordings, :is_lma, :boolean
  end
end
