class AddLocationDetailsToVenues < ActiveRecord::Migration[8.1]
  def change
    add_column :venues, :latitude, :decimal, precision: 10, scale: 7
    add_column :venues, :longitude, :decimal, precision: 10, scale: 7
    add_column :venues, :address, :string
  end
end
