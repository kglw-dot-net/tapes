class AddParentToTapers < ActiveRecord::Migration[8.0]
  def change
    add_reference :tapers, :parent, foreign_key: { to_table: :tapers }
  end
end
