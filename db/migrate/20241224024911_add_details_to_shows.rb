class AddDetailsToShows < ActiveRecord::Migration[8.0]
  def change
    add_column :shows, :songfishID, :integer
    add_column :shows, :songfishPermalink, :string
    add_column :shows, :title, :string
    add_column :shows, :order, :integer
    add_column :shows, :slug, :string
    add_column :shows, :notes, :text
  end
end
