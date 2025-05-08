class AddContinentRefToCountries < ActiveRecord::Migration[8.0]
  def change
    add_reference :countries, :continent, null: false, foreign_key: true
  end
end
