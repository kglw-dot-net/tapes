class AddIsAnonToTapers < ActiveRecord::Migration[8.0]
  def change
    add_column :tapers, :is_anon, :boolean, null: false, default: false
  end
end
