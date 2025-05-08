class CreateShows < ActiveRecord::Migration[8.0]
  def change
    create_table :shows do |t|
      t.date :date

      t.timestamps
    end
  end
end
