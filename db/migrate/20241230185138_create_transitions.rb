class CreateTransitions < ActiveRecord::Migration[8.0]
  def change
    create_table :transitions do |t|
      t.integer :songfishID
      t.string :separator

      t.timestamps
    end
  end
end
