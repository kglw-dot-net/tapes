class AddSlugToCountries < ActiveRecord::Migration[8.0]
  def change
    add_column :countries, :slug, :string
  end
end
