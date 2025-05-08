class AddShowToRecordings < ActiveRecord::Migration[8.0]
  def change
    add_reference :recordings, :show, null: true, foreign_key: true
  end
end
