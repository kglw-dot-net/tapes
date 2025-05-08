class AddCountryToVenues < ActiveRecord::Migration[8.0]
  def change
    add_reference :venues, :country, null: true, foreign_key: true
  end
end
