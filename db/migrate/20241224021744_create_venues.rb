class CreateVenues < ActiveRecord::Migration[8.0]
  def change
    create_table :venues do |t|
      t.string :name
      t.string :city
      t.string :region
      t.integer :songfishID
      t.string :slug

      t.timestamps
    end
  end
end
