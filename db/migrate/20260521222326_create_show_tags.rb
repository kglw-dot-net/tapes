class CreateShowTags < ActiveRecord::Migration[8.0]
  def change
    create_table :show_tags do |t|
      t.string :name
      t.string :slug

      t.timestamps
    end
  end
end
