class CreateRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :recordings, id: :string do |t|
      t.text :source
      t.text :lineage
      t.text :notes

      t.timestamps
    end
  end
end
