class CreateArtists < ActiveRecord::Migration[8.1]
  def change
    create_table :artists do |t|
      t.string :name
      t.integer :songfishID

      t.timestamps
    end
  end
end
