class AddSlugToArtists < ActiveRecord::Migration[8.1]
  def change
    add_column :artists, :slug, :string
  end
end
