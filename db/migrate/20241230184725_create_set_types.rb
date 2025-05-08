class CreateSetTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :set_types do |t|
      t.integer :songfishID
      t.string :separator

      t.timestamps
    end
  end
end
