class CreateTours < ActiveRecord::Migration[8.0]
  def change
    create_table :tours do |t|
      t.string :name
      t.integer :songfishID

      t.timestamps
    end
  end
end
