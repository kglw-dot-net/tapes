class CreateSetlists < ActiveRecord::Migration[8.0]
  def change
    create_table :setlists do |t|
      t.references :show, null: false, foreign_key: true
      t.integer :setnumber
      t.references :set_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
